import common.Release

def j = new Release
	(
		name: 'Win64_GNU_MSI',
		libraries: 'Win64_GNU',
		label: 'Windows',
		artifacts: 'libs/Toolchain_*,build/*.msi*,build/Appcast*',
		weight: 2
	).generate(this)


j.with
{
	steps
	{
		batchFile('cmake -P source/ci.cmake')
	}
}
