public const string PREFIX_COMMIT = "\033[35;1m[SupraCommit]\033[0m: ";

public void main (string []av) {
	Intl.setlocale ();

	try {
		var options = new ParseOption();
		options.parse (av);

		run_supracommit ();
	}
	catch (Error e) {
		printerr (PREFIX_COMMIT + "\033[1;31mCritical Failure:\033[0m %s\n", e.message);
	}
}
