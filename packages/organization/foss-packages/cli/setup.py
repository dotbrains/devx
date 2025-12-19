from setuptools import setup, find_packages

setup(
    name='foss-cli',
    version='1.0.0',
    description='FOSS Package Management CLI',
    packages=find_packages(),
    install_requires=[
        'click>=8.1.0',
        'requests>=2.31.0',
        'rich>=13.7.0',
    ],
    entry_points={
        'console_scripts': [
            'foss-cli=foss_cli.app:main',
        ],
    },
    python_requires='>=3.8',
)
