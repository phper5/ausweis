import common.Review
import static common.Constants.strip

def j = new Review
	(
		name: 'SonarQube',
		label: 'Vanilla',
		artifacts: 'tmp/*.log,tmp/sonar-metadata.txt',
		excludePattern: 'source/**,sonar/**',
		allowEmptyArtifacts: true,
		xunit: true
	).generate(this)


j.with
{
	wrappers
	{
		environmentVariables
		{
			env("XDG_RUNTIME_DIR", '$WORKSPACE/tmp')
			env("SONAR_USER_HOME", '$WORKSPACE/sonar/home')
		}
	}

	steps
	{
		shell('cmake -DSPLIT=OFF -P source/ci.cmake')
	}
}
