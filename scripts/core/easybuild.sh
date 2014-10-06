# Install EasyBuild
# NB : environment-modules installed in bootstrap.sh

# Si ne marche pas, verifier que python --version >= 2.4
wget https://raw.github.com/hpcugent/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py
python bootstrap_eb.py /usr/bin/.local/easybuild
echo "MODULEPATH=/usr/bin/.local/easybuild/modules/all:$MODULEPATH" >> /etc/environment

