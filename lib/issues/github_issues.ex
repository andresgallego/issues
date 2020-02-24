defmodule Issues.GithubIssues do
  require Logger

  @user_agent [ {"User-agent", "andresgallego85@gmail.com"} ]

  # Use a module attribute to fetch the value at compile time
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status code=#{status_code}")
    Logger.debug(fn -> inspect(body) end)
    {
      status_code |> check_for_error(),
      body |> Poison.Parser.parse!(%{})
    }
  end

  def handle_response({:error, %{reason: reason}}) do
    { :error, reason }
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end