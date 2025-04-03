#!/bin/bash
# generate_requirements.sh
pip3 freeze > requirements.txt
echo "Generated requirements.txt with exact versions."
