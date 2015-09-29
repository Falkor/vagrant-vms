-*- mode: markdown; mode: visual-line; fill-column: 80 -*-
`README.md`

Copyright (c) 2014 [Sebastien Varrette](mailto:<Sebastien.Varrette@uni.lu>) [www](http://varrette.gforge.uni.lu)

        Time-stamp: <Tue 2015-09-29 10:34 svarrette>

-------------------

# Vagrant VMs

Management and Generation of customized [Vagrant](http://www.vagrantup.com/) boxes (using [packer](http://www.packer.io/) and [veewee](https://github.com/jedi4ever/veewee))

## Synopsis

The repository is meant to facilitate the generation of [Vagrant](http://www.vagrantup.com/) boxes from the numerous [templates](https://github.com/jedi4ever/veewee/tree/master/templates) offered by [VeeWee](https://github.com/jedi4ever/veewee) -- a tool for easily (and repeatedly) building custom Vagrant base boxes, KVMs, and virtual machine images.
Internally, [veewee-to-packer](https://github.com/mitchellh/veewee-to-packer) is used to make the magical conversion.

## Pre-requisite

### Virtualbox / Vagrant 

I made a [short talk](https://hpc.uni.lu/hpc-school/slides/2015-06-25-UL-HPC-School_2015_keynote3_vagrant.pdf)  explaining Vagrant together with some installation notes. So you are more than encourage to take a look at it

* [slides (PDF)](https://hpc.uni.lu/hpc-school/slides/2015-06-25-UL-HPC-School_2015_keynote3_vagrant.pdf) 



### Repository Setup

First clone this repository: 

     $> git clone https://github.com/Falkor/vagrant-vms.git
     $> cd vagrant-vms

Ensure [RVM](https://rvm.io/) is correctly configured for this repository:

     $> rvm current

Configure the gem dependencies:

     $> gem install bundler
     $> bundle install
     $> rake -T     # should work ;) 

Configure the repository and its dependencies:
        
     $> rake setup

## Prepare a new OS template

You can initiate a template for a given Operating System:

     $> rake packer:{Debian,CentOS,openSUSE,scientificlinux,ubuntu}:init
     
The template is generated in the `packer/` script. You'll have to answer a couple of questions, including the version of the OS 

 (for instance `packer/debian-7.5.0-amd64`).
     
## Build a Vagrant box

Once you have generated a template, you can build the corresponding Vagrant box
using 

     $> rake packer:{Debian,CentOS,openSUSE,scientificlinux,ubuntu}:build

If everything goes fine, you shall find your freshly generated box in
`packer/<os>-<version>-<arch>/<os>-<version>-<arch>.box` that you can then add
to your local box by running 

     $> vagrant box add packer/<os>-<version>-<arch>/<os>-<version>-<arch>.box

## Customizations

__(in progress)__ Customization of the generated box is based on
[puppet](http://puppetlabs.com/) and can be performed by the definition of
profiles in the `puppet/`. 

For each profile, a `Puppetfile` needs to be defined since the puppet
environment will be later on initialized within the packer process using
[librarian-puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k). 
Then the appropriate manifest shall be defined.

## Repackage a box

Assuming you made some final customization on your box, you can commit the changes you applied, you can package again the box (assuming the box is still up and running and configure to suit your tastes) via `vagrant package`


* Clean the VM to save some space. For that, you can invoke the `zerodisk.sh` script embedded in packer that has the following content:

        #!/bin/bash
        # Zero out the free space to save space in the final image:
        dd if=/dev/zero of=/EMPTY bs=1M
        rm -f /EMPTY

* Ensure that the `~vagrant/.ssh/authorized_keys` hold the **default** public key used through all Vagrant public images
     - see [vagrant key pair on Github](https://github.com/mitchellh/vagrant/tree/master/keys)
     - by default, this key is judged (on purpose) insecure and thus is overwritten with a new (random) key pair unless you set [`config.ssh.insert_key`](https://docs.vagrantup.com/v2/vagrantfile/ssh_settings.html) to `false` (default is `true`). 
     - add it as follows:

            $> sudo -u vagrant wget -O ~vagrant/.ssh/authorized_keys \
                   --no-check-certificate \
                   https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub

* Ensure the Guest additions for Virtualbox match. For that, you can rely on the [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

        $> vagrant plugin install vagrant-vbguest
        $> vagrant vbguest --status
        GuestAdditions versions on your host (5.0.4) and guest (4.3.26) do not match.

  In case of a mismatch, you can easily install the latest Guest additions within your **running** VM by running (you can safely ignore the error on Window System drivers):

        $> vagrant vbguest --do install --auto-reboot
        $> vagrant halt
        $> vagrant up
        [...]
        GuestAdditions 5.0.4 running --- OK.


* locate the name of the running VM by opening `VirtualBox` (`vagrant-vms_default_1431034026308_70455` in the below example). Use the following command for that:

        $> VBoxManage list runningvms

Create the box (which will generate the file `package.box`) that you can then rename and share

        $> vagrant package \
            --base vagrant-vms_default_1431034026308_70455 \
            --output packer/<os>-<version>-<arch>/<os>-<version>-<arch>.box  # adapt accordingly
 

Now you can upload the generated box on [Vagrant Cloud](http://vagrantcloud.com).

* select 'New version', enter the new version number, and add a new box provider (`Virtualbox`) to upload the generated box.
* Remember upon successful upload to **release** the uploaded box (by default it is unreleased).


## Git Branching Model

The Git branching model for this repository follows the guidelines of
[gitflow](http://nvie.com/posts/a-successful-git-branching-model/).  
In particular, the central repository holds two main branches with an infinite
lifetime:  

* `production`: the branch holding tags of the successive releases of this tutorial
* `devel`: the main branch where the sources are in a state with the latest delivered development changes for the next release. This is the *default* branch you get when you clone the repo, and the one on which developments will take places. 

You should therefore install [git-flow](https://github.com/nvie/gitflow), and
probably also its associated
[bash completion](https://github.com/bobthecow/git-flow-completion).  
Also, to facilitate the tracking of remote branches, you probably wants to
install [grb](https://github.com/webmat/git_remote_branch) (typically via ruby
gems).  

Then, to make your local copy of the repository ready to use my git-flow
workflow, you have to run the following commands once you cloned it for the
first time: 

      $> rake setup 

## Resources

### Git 

You should become familiar (if not yet) with Git. Consider these resources: 

* [Git book](http://book.git-scm.com/index.html)
* [Github:help](http://help.github.com/mac-set-up-git/)
* [Git reference](http://gitref.org/)

### Links

* [Issues](https://github.com/Falkor/vagrant-vms/issues)
* [GitHub](https://github.com/Falkor/vagrant-vms)
