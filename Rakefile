##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Wed 2015-09-23 15:11 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
#                       ____       _         __ _ _
#                      |  _ \ __ _| | _____ / _(_) | ___
#                      | |_) / _` | |/ / _ \ |_| | |/ _ \
#                      |  _ < (_| |   <  __/  _| | |  __/
#                      |_| \_\__,_|_|\_\___|_| |_|_|\___|
#
# Use 'rake -T' to list the available actions
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Resources:
# * http://www.stuartellis.eu/articles/rake/
# * Pascal Morillon's Capfile for the Grid5000 puppet repository
##############################################################################

require 'falkorlib'
require 'json'
require 'pathname'

# Adapt the Git flow aspects
FalkorLib.config.gitflow do |c|
    c[:branches] = {
        :master  => 'production',
        :develop => 'devel'
    }
end

# Configure the git submodules
FalkorLib.config.git do |c|
    c[:submodules] = {
        'veewee' => {
            :url => 'https://github.com/Falkor/veewee.git'
        }
    }
end

# Git[Flow] and Versioning management
require "falkorlib/tasks/git"    # OR require "falkorlib/git_tasks"

##############################################################################
TOP_SRCDIR = File.expand_path(File.join(File.dirname(__FILE__), "."))
VEEWEE_TEMPLATE_DIR = ".submodules/veewee/templates"
PACKER_TEMPLATE_DIR = 'packer'
SCRIPTS_DIR         = 'scripts'
PUPPET_DIR          = 'puppet'

# List of OS templates
raw_list = os_list = []
Dir["#{TOP_SRCDIR}/#{VEEWEE_TEMPLATE_DIR}/*"].each do |dir|
    if File.directory?(dir)
        entry = File.basename(dir)
        next if     (entry =~ /^windows-/ || entry =~ /^vmware-/i)
        next unless entry =~ /amd|x86_64/
        raw_list << entry
    end
end
os_list = raw_list.map {|e| e.scan(/^[^-|_]+/) }.flatten.uniq

#.....................
namespace :packer do


    ###########   check   ###########
    #desc "Check availability of the packer command"
    task :check do
        status =  command?('packer') ? green("OK") : red("FAILED")
        info "Check availability of the packer command.... #{status}"
        error "Unable to find the 'packer' command on your system. See http://www.packer.io/downloads.html for download instructions" unless command?('packer')
    end # task check


    os_list.select { |e| e =~ /deb|cen|scien|ubun|suse/i  }.each do |os|
        __version_list = raw_list.select { |e| e =~ /^#{os}/ }
        #__index = 1
        version_list = { 0 => 'Exit' }
        version_list.merge! Hash[__version_list.each_with_index.map { |value, index| [index+1, value] }]

        #.....................
        namespace os.to_sym do
            ###########   packer:{Debian,CentOS,openSUSE,scientificlinux,ubuntu}:init   ###########
            desc "Initialize the #{os} template image for vagrant "
            task :init do |t|
                info "#{t.comment}"
                #version_list = raw_list.select { |e| e =~ /^#{os}/ }
                v = select_from(version_list, "Select the supported #{os} version", 17)
                output_dir = File.join(PACKER_TEMPLATE_DIR, v.gsub(/-netboot$/, '').downcase)
                if File.directory?( File.join(TOP_SRCDIR, output_dir) )
                    warn "the directory #{output_dir} already exists"
                    really_continue?
                end
                jsonfile = File.join(TOP_SRCDIR, output_dir, "#{File.basename output_dir}.json")
                Dir.chdir(TOP_SRCDIR) do
                    run %{
                           veewee-to-packer -o #{output_dir} #{VEEWEE_TEMPLATE_DIR}/#{v}/definition.rb
                           packer fix #{output_dir}/template.json > #{jsonfile}
                           rm -f #{output_dir}/template.json
                        }
                    info "adapting #{os} scripts"
                    provision_scripts = []
                    Dir["#{TOP_SRCDIR}/#{SCRIPTS_DIR}/core/*", "#{TOP_SRCDIR}/#{SCRIPTS_DIR}/#{os}/*"].each do |f|
                        script = File.basename( f )
						puts "=> adding #{f}"
                        dstdir = Pathname.new( File.join(TOP_SRCDIR, output_dir, 'scripts') )
                        relative_path = Pathname.new( f ).relative_path_from(dstdir)
                        FileUtils.ln_s relative_path.to_s, File.join(dstdir, script ), :force => true
                        provision_scripts << "scripts/bootstrap.sh" if script == 'bootstrap.sh' && ! provision_scripts.include?(/bootstrap\.sh$/)
                    end
					# # Prepare puppet directory 
				    puppet_role = 'default'
				    # TODO: select puppet custom role
				    puppet_dstdir = Pathname.new( File.join(TOP_SRCDIR, output_dir) )
				    puppet_srcdir = Pathname.new( File.join(TOP_SRCDIR, PUPPET_DIR, puppet_role) )
				    # puts "puppet_dstdir = #{puppet_dstdir.to_s}"
				    # puts "puppet_srcdir = #{puppet_srcdir.to_s}"
				    puppetdir_relative_path = puppet_srcdir.relative_path_from( puppet_dstdir )
				    puts "rel path = #{puppetdir_relative_path.to_s}"
				    FileUtils.ln_s puppetdir_relative_path.to_s, "#{puppet_dstdir}/puppet", :force => true
                    # Eventual customization
                   #  begin
	               #      custom_item = list_items("#{TOP_SRCDIR}/#{SCRIPTS_DIR}/#{os}/*",
                   #                               {
                   #                                   :text => "select the hook module to install",
                   #                                   :pattern_exclude => [ 
                   #                                                        '^bootstrap',
                   #                                                       ],
		           #                                   :only_files => true
                   #                               })
                   #      provision_scripts << "scripts/#{custom_item}"
                   # rescue SystemExit
                   #      info "Installation without any specific customization"
                   #  end
                    packer_config = JSON.parse( IO.read( jsonfile ) )
					# [Librarian-]puppet specialization
					# TODO: select appropriate Puppetfile
					packer_vagrantfile_entry = {
						"type"        => "file",
						"source"      => "puppet/Puppetfile",
						"destination" =>  "/tmp/Puppetfile"
					}
					# motd_entry = {
					# 	"type"   =>  "shell",
					# 	"script" =>  "scripts/motd.sh",
					# 	"execute_command" => "echo 'packer' | {{ .Vars }} sudo -E -S sh '{{ .Path }}"
					# }
					#packer_config['provisioners'].unshift 
                    packer_config['variables'] = {} if packer_config['variables'].nil?
                    packer_config['provisioners'].each do |p|
                        if ! provision_scripts.empty? && p['scripts']
                            provision_scripts.each { |s|  p['scripts'].unshift s }
                        end	
						Dir["#{TOP_SRCDIR}/#{SCRIPTS_DIR}/core/*"].each do |f| 
							script = File.basename( f )
							if script =~ /motd/
								{
									:name     => "#{v}",
									:title    => 'Vagrant Testbox',
									:subtitle => "#{os}",
									:desc     => "Generic #{os} testing box",
									:support  => "#{ENV['GIT_AUTHOR_EMAIL']}"
								}.each do |k,v| 
									ans = ask("[motd] Vagrant box #{k}", v)
                                    packer_config['variables']["motd_#{k}"] = "#{ans}"
									# packer_config["variables"] = { } if packer_config["variables"].nil?
									# packer_config["variables"][ "motd_#{k}"] = "#{ans}" unless ans.empty?
									p['environment_vars'] = [] if p['environment_vars'].nil?
                                    #p[]
									p['environment_vars'] << "MOTD_#{k.upcase}=" + '{{ user `motd_' + "#{k}" + '`}}'
									#motd_entry["execute_command"] += " --#{k} \"#{ans}\""  
								end
								#motd_entry["execute_command"] += "'"
							end #else 
							p['scripts'] << "scripts/#{script}" 
							#end 
						end
                        if p['override']
                            [ 'virtualbox', 'vmware' ].each do |os|
                                if p['override'][ os ]
                                    puts "=> adapting the provisioners '#{os}' to '#{os}-iso'"
                                    p['override'][ "#{os}-iso" ] = p['override'].delete os
                                end
                            end
                        end
                        if p['scripts']
	                        p['scripts'].each do |entry| 
								[ 'chef' ].each do |script|
									next unless entry =~ /#{script}/
									puts "=> removing provisioners script '#{script}.sh'"
									p['scripts'].delete entry
								end 
							end
	                        #         #p['scripts'].delete "scripts/#{scripts}"
                        end
                    end
					packer_config['provisioners'].unshift packer_vagrantfile_entry
                    #packer_config['provisioners'] << motd_entry
					#ap packer_config['builders']
                    packer_config['builders'].each do |builder|
                        if builder['boot_command']
                            puts "=> remove useless <wait>"
                            builder['boot_command'].each do |cmd|
                                next if cmd =~ /^<esc>/ || cmd =~ /^<enter>/
                                cmd.gsub!(/<wait>/, '')
                            end
                        end
                    end
                    vagrant_postproc = [
                                        {
                                            "type"                => "vagrant",
                                            "keep_input_artifact" => false,
                                            "output"              => "#{File.basename output_dir}.box"
                                        }
                                       ]
                    packer_config['post-processors'] = vagrant_postproc if packer_config['post-processors'].nil?


                    # Now store the new json
                    File.open(jsonfile,"w") do |f|
                        f.write JSON.pretty_generate(packer_config)
                    end

                end  # Dir.chdir...
                #end   # if .... else ....


            end # task init




            #puts "#{TOP_SRCDIR}/packer/#{os.downcase}*"
            unless Dir.glob("#{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/#{os.downcase}-*").empty?

                ###########   packer:{Debian,CentOS,openSUSE,scientificlinux,ubuntu}:build   ###########
                desc "Build an Vagrant box for the '#{os}' operating system"
                task :build do |t|
                    info "#{t.comment}"
                    box = list_items("#{PACKER_TEMPLATE_DIR}/#{os.downcase}-*",
                                     {
                                         :text => "Select the #{os} template image to build",
                                     })
                    info "about to build the box '#{box}' using packer"
                    really_continue?
                    Dir.chdir("#{TOP_SRCDIR}/#{box}/") do
                        Dir.glob("*.json").each do |jf|
                            json = File.basename("#{jf}")
                            s = run %{
                               PACKER_CACHE_DIR=#{TOP_SRCDIR}/.packer_cache  \
                               PACKER_LOG=yes   \
                               PACKER_LOG_PATH=#{TOP_SRCDIR}/#{box}/packer.log \
                                   packer build -only=virtualbox-iso #{json}
                            }
                            boxfile = File.join(TOP_SRCDIR, "#{box}", "#{File.basename box}.box")
                            puts "box file #{boxfile}"
                            puts s.to_i
                            info "the generated Vagrant box is '#{boxfile}'" if File.exists?( boxfile )
                            if File.exists?( boxfile )
                                y = ask("Shall it be added to vagrant (Y|n)", 'Yes')
                                run  %{
                                  vagrant box add #{File.basename box} #{boxfile}
                                } unless y =~ /n.*/i
                            end
                        end

                        # ap raw_list[box]
                        # raw_list[box].each do |jf|
                        #   json = File.basename("#{jf}")
                        #   info "patching JSON file '#{json}'"
                        # end

                    end # Dir.chdir ...
                end # task build


                ###########   packer:{Debian,CentOS,openSUSE,scientificlinux,ubuntu}:clean   ###########
                desc "Clean all templates generated for the '#{os}' operating system"
                task :clean do |t|
                    info "#{t.comment}"
                    run %{
                      rm -rf #{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/#{os.downcase}*
                    }
                end # task clean
            end


        end
    end


end # namespace packer

task :setup => 'packer:check'


#=======================================================================
# eof
#
# Local Variables:
# mode: ruby
# End:
