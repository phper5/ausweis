import common.Review

build = new Review
	(
		name: 'iOS_SwiftPackage',
		label: 'iOS',
		artifacts: 'build/dist/*.zip'
	)

def j = build.generate(this)


j.with
{
	parameters
	{
		stringParam('iOS_Framework_OS_Build', '', 'Build of iOS Framework for OS')
		stringParam('iOS_Framework_Simulator_x86_64_Build', '', 'Build of iOS Framework for Simulator-x86_64')
		stringParam('iOS_Framework_Simulator_arm64_Build', '', 'Build of iOS Framework for Simulator-arm64')
	}

	steps
	{
		copyArtifacts(build.getSourceJobName('iOS_Framework_OS'))
		{
			targetDirectory('arm64')
			flatten()
			buildSelector
			{
				buildNumber('${iOS_Framework_OS_Build}')
			}
		}

		copyArtifacts(build.getSourceJobName('iOS_Framework_Simulator_x86_64'))
		{
			targetDirectory('x86_64-simulator')
			flatten()
			buildSelector
			{
				buildNumber('${iOS_Framework_Simulator_x86_64_Build}')
			}
		}

		copyArtifacts(build.getSourceJobName('iOS_Framework_Simulator_arm64'))
		{
			targetDirectory('arm64-simulator')
			flatten()
			buildSelector
			{
				buildNumber('${iOS_Framework_Simulator_arm64_Build}')
			}
		}

		shell('cmake -P source/ci.cmake')
	}
}
