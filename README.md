-*- mode: markdown; mode: auto-fill; fill-column: 80 -*-
`README.md`

Copyright (c) 2014 [Sebastien Varrette](mailto:<Sebastien.Varrette@uni.lu>) [www](http://varrette.gforge.uni.lu)

        Time-stamp: <Ven 2014-09-05 22:10 svarrette>

-------------------

# Vagrant VMs

Management and Generation of customized [Vagrant](http://www.vagrantup.com/)
boxes (using [packer](http://www.packer.io/) and
[veewee](https://github.com/jedi4ever/veewee))


## Synopsis

The repository is meant to facilitate the generation of
[Vagrant](http://www.vagrantup.com/) boxes from the 
numerous [templates](https://github.com/jedi4ever/veewee/tree/master/templates)
offered by [VeeWee](https://github.com/jedi4ever/veewee) -- a tool for easily
(and repeatedly) building custom Vagrant base boxes, KVMs, and virtual machine
images.
Internally, [veewee-to-packer](https://github.com/mitchellh/veewee-to-packer) is
used to make the magical conversion.

## Pre-requisite

First clone this repository: 

     $> git clone https://github.com/Falkor/vagrant-vms.git
     $> cd vagrant-vms

Configure [RVM](https://rvm.io/) For that repository:

     $> echo 'vagrant-vms' > .ruby-gemset
     $> echo '2.1.0'       > .ruby-version
     $> rvm install `cat .ruby-version`
     $> cd .. && cd -

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
