defmodule GitOpenTest do
  use ExUnit.Case
  doctest GitOpen
  import GitOpen

  describe ".to_browser_url" do
    test "convert github" do
      assert to_browser_url("ssh://github.com:qhwa/project.git") == "https://github.com/qhwa/project"
    end
  end
end
