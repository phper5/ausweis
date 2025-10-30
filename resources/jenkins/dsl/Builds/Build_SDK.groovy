import common.Build
import common.Build.JobType
import common.Constants
import static common.Constants.getEnvNumber

String getName(String name)
{
	return "${MERCURIAL_REVISION_BRANCH}_" + name
}

def j = new Build
	(
		name: 'SDK',
		label: 'Trigger',
		jobType: JobType.Multi,
		oldBuilds: [1, 1]
	).generate(this)


j.with
{
	steps {
		phase('Build') {
			for(ARCH in Constants.AndroidArch)
			{
				phaseJob(getName('Android_AAR_' + ARCH))
			}

			phaseJob(getName('iOS_Framework_OS'))

			phaseJob(getName('iOS_Framework_Simulator_x86_64'))

			phaseJob(getName('iOS_Framework_Simulator_arm64'))
		}
		phase('Combine') {
			phaseJob(getName('Android_AAR'))
			{
				parameters
				{
					for(ARCH in Constants.AndroidArch)
					{
						predefinedProp('Android_AAR_' + ARCH.replace('-', '_'), getEnvNumber(getName('Android_AAR_' + ARCH)))
					}
				}
			}

			phaseJob(getName('iOS_SwiftPackage'))
			{
				parameters
				{
					predefinedProp('iOS_Framework_OS_Build', getEnvNumber(getName('iOS_Framework_OS')))
					predefinedProp('iOS_Framework_Simulator_x86_64_Build', getEnvNumber(getName('iOS_Framework_Simulator_x86_64')))
					predefinedProp('iOS_Framework_Simulator_arm64_Build', getEnvNumber(getName('iOS_Framework_Simulator_arm64')))
				}
			}
		}
	}
}
