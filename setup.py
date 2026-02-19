"""Setup for trinity-market CLI tool."""

from setuptools import setup

setup(
    name="trinity-market",
    version="0.2.0",
    description="CLI tool for installing agents from the Trinity marketplace",
    author="Vybe",
    py_modules=["trinity_market"],
    install_requires=["requests>=2.28", "pyyaml>=6.0"],
    entry_points={
        "console_scripts": [
            "trinity-market=trinity_market:main",
        ],
    },
    python_requires=">=3.10",
)
