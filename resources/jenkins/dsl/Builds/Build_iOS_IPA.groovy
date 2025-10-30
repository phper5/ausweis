import common.Build

def j = new Build
	(
		name: 'iOS_IPA',
		libraries: 'iOS_OS',
		label: 'iOS',
		artifacts: 'build/*.ipa,build/*.zip,build/*.bcsymbolmap'
	).generate(this)


j.with
{
	steps
	{
		shell('cmake -P source/ci.cmake')
	}
}
