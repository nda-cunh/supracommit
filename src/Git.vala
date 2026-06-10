namespace Git {
    /**
    * Retrieves the last commit messages from the git log.
    * @param count The number of last commit messages to retrieve.
    * @return An array of the last commit messages.
    * @throws Error If there is an issue executing the git command.
    */
    public string[] last_commits (int count) throws Error {
        string output;
        string errput;
        int status;

		if (count <= 0)
			return {};

        Process.spawn_command_line_sync("git log -n " + count.to_string() + " --pretty=format:%s", out output, out errput, out status);

        if (status != 0)
            return {};

        return output.split("\n");
    }

	/**
	* Executes the git commit command with the provided message.
	* @param message The commit message to use for the git commit.
	* @throws Error If there is an issue executing the git command.
	*/
	public void commit (string message) throws Error {
		string msg = "git commit -m " + Shell.quote(message);
		string output;
		string errput;
		int status;

		Process.spawn_command_line_sync(msg, out output, out errput, out status);

		if (status != 0)
			throw new SupraCommitError.GIT_ERROR("Git: %s", errput);

		print(PREFIX_COMMIT + " \033[1;32mDone!\033[0m Changes committed successfully.\n");
	}

	/**
	* Retrieves the git diff of staged changes and the repository path.
	* @param repo_path An output parameter that will contain the path to the git repository.
	* @return The git diff of staged changes as a string.
	* @throws Error If there is an issue executing the git commands.
	*/
	public string diff (out string repo_path) throws Error {
		string output;
		string errput;
		int status;

		Process.spawn_command_line_sync("git rev-parse --show-toplevel", out output, out errput, out status);

		if (status != 0)
			throw new SupraCommitError.GIT_ERROR("Git: %s", errput);

		repo_path = output._strip();

		Process.spawn_command_line_sync("git diff --cached", out output, out errput, out status);

		if (status != 0)
			throw new SupraCommitError.GIT_ERROR("Git: %s", errput);

		output._strip();
		return (owned)output;
	}
}
