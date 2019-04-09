import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="sec-an-shared-python",
    version="0.0.1",
    description="Security analytics platform shared code",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/ministryofjustice/securityanalytics-sharedinfrastructure",
    packages=setuptools.find_packages()
)