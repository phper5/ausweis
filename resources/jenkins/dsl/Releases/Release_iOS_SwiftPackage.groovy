import common.Release

build = new Release
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
		buildSelectorParam('iOS_Framework_OS_Build')
		{
			defaultBuildSelector
			{
				latestSuccessful(true)
			}
			description('Build to get iOS Framework OS artifacts from')
		}

		buildSelectorParam('iOS_Framework_Simulator_x86_64_Build')
		{
			defaultBuildSelector
			{
				latestSuccessful(true)
			}
			description('Build to get iOS Framework (Simulator-x86_64) artifacts from')
		}
		buildSelectorParam('iOS_Framework_Simulator_arm64_Build')
		{
			defaultBuildSelector
			{
				latestSuccessful(true)
			}
			description('Build to get iOS Framework (Simulator-arm64) artifacts from')
		}
	}

	steps
	{
		copyArtifacts(build.getSourceJobName('iOS_Framework_OS'))
		{
			targetDirectory('arm64')
			flatten()
			buildSelector
			{
				buildParameter('iOS_Framework_OS_Build')
			}
		}

		copyArtifacts(build.getSourceJobName('iOS_Framework_Simulator_x86_64'))
		{
			targetDirectory('x86_64-simulator')
			flatten()
			buildSelector
			{
				buildParameter('iOS_Framework_Simulator_x86_64_Build')
			}
		}

		copyArtifacts(build.getSourceJobName('iOS_Framework_Simulator_arm64'))
		{
			targetDirectory('arm64-simulator')
			flatten()
			buildSelector
			{
				buildParameter('iOS_Framework_Simulator_arm64_Build')
			}
		}

		shell('cmake -P source/ci.cmake')
	}
}
