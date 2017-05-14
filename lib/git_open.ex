defmodule GitOpen do
  @moduledoc """
  Documentation for GitOpen.
  """

  @doc """
  Convert git remote url into browsable url.

  ## Examples

      iex> GitOpen.to_browser_url("ssh://git@github.com:qhwa/git-open.git")
      "https://github.com/qhwa/git-open"

      iex> GitOpen.to_browser_url("ssh://git@hlj.team:qhwa/git-open.git")
      "https://hlj.team/qhwa/git-open"

      iex> GitOpen.to_browser_url("ssh://git@hlj.team:qhwa/git-open.git", host: "git.hlj.team")
      "https://git.hlj.team/qhwa/git-open"

      iex> GitOpen.to_browser_url("ssh://git@hlj.team:qhwa/git-open.git", port: 10080)
      "https://hlj.team:10080/qhwa/git-open"

      iex> GitOpen.to_browser_url("ssh://git@hlj.team:8080/qhwa/git-open.git", schema: :http)
      "http://hlj.team/qhwa/git-open"

  """
  def to_browser_url(remote_url, opts \\ []) do
    match = ~r'(ssh://)?((.+)@)?(?<host>[^/:]+)((:\d+)/|:)(?<user>.+)/(?<project>.+)\.git$'fx
    |> Regex.run(remote_url, capture: :all_names)

    case match do
      [host, project, user] ->
        schema = Keyword.get(opts, :schema, :https)
        host = opts
        |> Keyword.get(:host, host)
        |> get_host(Keyword.get(opts, :port))

        "#{schema}://#{host}/#{user}/#{project}"
      _ ->
        remote_url
    end
  end

  defp get_host(hostname, nil), do: hostname
  defp get_host(hostname, port), do: "#{hostname}:#{port}"


  def open do
    {git_url, 0} = System.cmd("git", ["config", "--get", "remote.origin.url"], [])
    git_url |> to_browser_url |> open_in_browser(get_opener())
  end


  defp open_in_browser(_, nil), do: {:error, :noopener}

  defp open_in_browser(url, {opener, args}) do
    System.cmd(opener, args ++ [url])
  end

  defp open_in_browser(url, opener) do
    System.cmd(opener, [url])
  end

  defp get_opener do
    case System.cmd("uname", ["-s"]) do
      {"Darwin\n", 0}     -> "open"
      {"MINGW" <> _, 0}   -> "start"
      {"CYGWIN" <> _, 0}  -> "cygstart"
      {"MSYS" <> _, 0}    -> {"powershell.exe", ["–NoProfile", "Start"]}
      _                   -> System.get_env("BROWSER")
    end
  end


end
