##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Mer 2014-08-20 17:09 svarrette>
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
            :url    => 'https://github.com/jedi4ever/veewee.git'
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

    # ###########   build   ###########
    # desc "Build a Vagrant image from a previously generated template"
    # task :build do |t|
    #     info "#{t.comment}"
    #     list = { 0 => 'Exit' }
    #     index = 1
    #     raw_list = {}
    #     Dir["#{TOP_SRCDIR}/packer/*"].each do |dir|
    #         if File.directory?(dir)
    #             entry = File.basename(dir)
    #             json = Dir.glob("#{dir}/*.json")
    #             next if json.empty?
    #             list[index] = entry
    #             raw_list[entry] = json
    #             index += 1
    #         end
    #     end
    #     #puts raw_list.inspect
    #     box = select_from_list("Select the Vagrant box to build using packer", list)
    #     info "about to build the box '#{box}' using packer"
    #     really_continue?
    #     Dir.chdir("#{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/#{box}") do
    #         raw_list[box].each do |jf|
    #             json = File.basename("#{jf}")
    #             info "patching JSON file '#{json}'"
    #             packer_config = JSON.parse( IO.read( json) )
    #             packer_config['provisioners'].each do |p|
    #                 #puts p['override'].to_yaml
    #                 next unless p['override']
    #                 [ 'virtualbox', 'vmware' ].each do |os|
    #                     p['override'][ "#{os}-iso" ] = p['override'].delete os if p['override'][ os ]
    #                 end
    #             end
    #             # Now store the new json
    #             File.open(json,"w") do |f|
    #                 f.write JSON.pretty_generate(packer_config)
    #             end
    #             s = run %{
    #                #pwd
    #                packer build -only=virtualbox-iso #{json}
    #             }
    #             boxfile = File.join(TOP_SRCDIR, PACKER_TEMPLATE_DIR, box, "#{box}.box")
    #             puts "box file #{boxfile}"
    #             info "the generated Vagrant box is '#{boxfile}'" if s.to_i == 0 && File.exists?( boxfile )

    #             #if File.exists?("#{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/#{box})
    #         end
    #     end

    # end # task build



    ###########   check   ###########
    #desc "Check availability of the packer command"
    task :check do |t|
        status =  command?('packer') ? green("OK") : red("FAILED")
        info "#{t.comment}.... #{status}"
        error "Unable to find the 'packer' command on your system. See http://www.packer.io/downloads.html for download instructions" unless command?('packer')
    end # task check


    os_list.select { |e| e =~ /deb|cen|scien|ubun|suse/i  }.each do |os|
        __version_list = raw_list.select { |e| e =~ /^#{os}/ }
        #__index = 1
        version_list = { 0 => 'Exit' }
        version_list.merge! Hash[__version_list.each_with_index.map { |value, index| [index+1, value] }]

        #.....................
        namespace os.to_sym do
            ###########   init   ###########
            desc "Initialize the #{os} template image for vagrant "
            task :init do |t|
                info "#{t.comment}"
                #version_list = raw_list.select { |e| e =~ /^#{os}/ }
                v = select_from(version_list, "Select the supported #{os} version")
                output_dir = File.join(PACKER_TEMPLATE_DIR, v.gsub(/-netboot$/, '').downcase)
                if File.directory?( File.join(TOP_SRCDIR, output_dir) )
                    warn "the directory #{output_dir} already exists"
                else
                    jsonfile = File.join(TOP_SRCDIR, output_dir, "#{File.basename output_dir}.json")
                    Dir.chdir(TOP_SRCDIR) do
                        run %{
                           veewee-to-packer -o #{output_dir} #{VEEWEE_TEMPLATE_DIR}/#{v}/definition.rb
                           packer fix #{output_dir}/template.json > #{jsonfile}
                           rm -f #{output_dir}/template.json
                        }
                        info "adapting #{os} scripts"
                        provision_scripts = []
                        Dir["#{TOP_SRCDIR}/#{SCRIPTS_DIR}/#{os}/*"].each do |f|
                            script = File.basename( f )
                            puts "=> adding #{SCRIPTS_DIR}/#{os}/#{script}"
                            dstdir = Pathname.new( File.join(TOP_SRCDIR, output_dir, 'scripts') )
                            relative_path = Pathname.new( f ).relative_path_from(dstdir)
                            FileUtils.ln_s relative_path.to_s, File.join(dstdir, script ), :force => true
                            provision_scripts << "scripts/bootstrap.sh" if script == 'bootstrap.sh' && ! provision_scripts.include?(/bootstrap\.sh$/)
                        end
                        # Eventual customization
                        begin
                            custom_item = list_items("#{SCRIPTS_DIR}/#{os}/*",
                                                     {
                                                         :text => "select the hook module to install",
                                                         :pattern_exclude => [ '^bootstrap']
                                                     })
                            provision_scripts << "scripts/#{custom_item}"
                        rescue SystemExit
                            info "Installation without any specific customization"
                        end
                        packer_config = JSON.parse( IO.read( jsonfile ) )
                        packer_config['provisioners'].each do |p|
                            if ! provision_scripts.empty? && p['scripts']
                                provision_scripts.each { |s|  p['scripts'].unshift s }
                            end
                            if p['override']
                                [ 'virtualbox', 'vmware' ].each do |os|
                                    if p['override'][ os ]
                                        puts "=> adapting the provisioners '#{os}' to '#{os}-iso'"
                                        p['override'][ "#{os}-iso" ] = p['override'].delete os
                                    end
                                end
                            end
                        end
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
                end   # if .... else ....


            end # task init




            #puts "#{TOP_SRCDIR}/packer/#{os.downcase}*"
            unless Dir.glob("#{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/#{os.downcase}-*").empty?

                ###########   build   ###########
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
                               packer build -only=virtualbox-iso #{json}
                            }
                            boxfile = File.join(TOP_SRCDIR, "#{box}.box")
                            puts "box file #{boxfile}"
                            puts s.to_i
                            info "the generated Vagrant box is '#{boxfile}'" if s.to_i == 0 && File.exists?( boxfile )
                            if File.exists?( boxfile )
                                y = ask("Shall it be added to vagrant (Y|n)", 'Yes')
                                run  %{
                                  vagrant box add #{box} #{boxfile}
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


                ###########   clean   ###########
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



    #     #.....................
    #     namespace :template do

    #         ###########   clean   ###########
    #         desc "Clean all the generated templates"
    #         task :clean do |t|
    #             info "#{t.comment}"
    #             run %{
    #                 rm -rf #{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/*
    #             }
    #         end # task packer:template:clean

    #         ###########   template:generate   ###########
    #         desc "Generate a new template using veewee-to-packer"
    #         task :generate => [ 'packer:check' ] do |t|
    #             info "List of supported Operating systems"
    #             list = { 0 => 'Exit' }
    #             index = 1
    #             # raw_list = os_list = []
    #             # Dir["#{TOP_SRCDIR}/#{VEEWEE_TEMPLATE_DIR}/*"].each do |dir|
    #             #     if File.directory?(dir)
    #             #         entry = File.basename(dir)
    #             #         next if     (entry =~ /^windows-/ || entry =~ /^vmware-/i)
    #             #         next unless entry =~ /amd|x86_64/
    #             #         raw_list << entry
    #             #     end
    #             # end
    #             # os_list = raw_list.map {|e| e.scan(/^[^-|_]+/) }.flatten.uniq
    #             os_list.each do |e|
    #                 list[index] = e
    #                 index+=1
    #             end
    #             os = select_from_list("Select a OS index from the list", list, 3)
    #             info "List of supported version for the #{os} OS"
    #             version_list = raw_list.select { |e| e =~ /^#{os}/ }
    #             list = Hash[version_list.each_with_index.map { |value, index| [index+1, value] }]
    #             list[0] = 'Exit'
    #             template = select_from_list("Select a version index from the list", list)
    #             output_dir = 'packer/' + template.gsub(/-netboot/, '').downcase
    #             if File.directory?("#{output_dir}")
    #                 warn "the directory #{output_dir} already exists"
    #             else
    #                 jsonfile = "#{output_dir}/#{File.basename output_dir}.json"
    #                 run %{
    #                    veewee-to-packer -o #{output_dir} #{VEEWEE_TEMPLATE_DIR}/#{template}/definition.rb
    #                    packer fix #{output_dir}/template.json > #{jsonfile}
    #                    rm -f #{output_dir}/template.json
    #                 }
    #                 info "adapting #{os} scripts"
    #                 provision_scripts = []
    #                 Dir["#{TOP_SRCDIR}/#{SCRIPTS_DIR}/#{os}/*"].each do |f|
    #                     script = File.basename( f )
    #                     puts "=> adding #{SCRIPTS_DIR}/#{os}/#{script}"
    #                     dstdir = Pathname.new( File.join(TOP_SRCDIR, output_dir, 'scripts') )
    #                     relative_path = Pathname.new( f ).relative_path_from(dstdir)
    #                     FileUtils.ln_s relative_path.to_s, File.join(dstdir, script ), :force => true
    #                     provision_scripts << "scripts/bootstrap.sh" if script == 'bootstrap.sh' && ! provision_scripts.include?(/bootstrap\.sh$/)
    #                 end
    #                 info "patching JSON file '#{jsonfile}'"
    #                 # Eventual customization
    #                 begin
    #                     custom_item = list_items("#{SCRIPTS_DIR}/#{os}/*",
    #                                              {
    #                                                  :text => "select the hook module to install",
    #                                                  :pattern_exclude => [ '^bootstrap']
    #                                              })
    #                     provision_scripts << "scripts/#{custom_item}"
    #                 rescue SystemExit
    #                     info "Installation without any specific customization"
    #                 end
    #                 packer_config = JSON.parse( IO.read( jsonfile ) )
    #                 packer_config['provisioners'].each do |p|
    #                     if ! provision_scripts.empty? && p['scripts']
    #                         provision_scripts.each { |s|  p['scripts'].unshift s }
    #                     end
    #                     if p['override']
    #                         [ 'virtualbox', 'vmware' ].each do |os|
    #                             if p['override'][ os ]
    #                                 puts "=> adapting the provisioners '#{os}' to '#{os}-iso'"
    #                                 p['override'][ "#{os}-iso" ] = p['override'].delete os
    #                             end
    #                         end
    #                     end
    #                 end
    #                 #ap packer_config['builders']
    #                 packer_config['builders'].each do |builder|
    #                     if builder['boot_command']
    #                         puts "=> remove useless <wait>"
    #                         builder['boot_command'].each do |cmd|
    #                             next if cmd =~ /^<esc>/ || cmd =~ /^<enter>/
    #                             cmd.gsub!(/<wait>/, '')
    #                         end
    #                     end
    #                 end
    #                 vagrant_postproc = [
    #                                     {
    #                                         "type"                => "vagrant",
    #                                         "keep_input_artifact" => false,
    #                                         "output"              => "#{File.basename output_dir}.box"
    #                                     }
    #                                    ]
    #                 packer_config['post-processors'] = vagrant_postproc if packer_config['post-processors'].nil?
    #                 #ap packer_config
    #                 # if packer_config['post-processors']
    #                 #     info "=> add vagrant post-processors"
    #                 #     ap packer_config['post-processors']


    #                 # end

    #                 # "post-processors": [{
    #                 #                         "type": "vagrant",
    #                 #                         "keep_input_artifact": false,
    #                 #                         "output": "box/{{.Provider}}/debian74-{{user `cm`}}{{user `cm_version`}}.box"
    #                 #                     }]


    #                 # Now store the new json
    #                 File.open(jsonfile,"w") do |f|
    #                     f.write JSON.pretty_generate(packer_config)
    #                 end


    #                 # packer_config = JSON.parse( IO.read( jsonfile) )

    #                 # packer_config[]
    #                 # ap packer_config
    #             end
    #             warn "consider running 'rake packer:build' now"
    #         end # task packer:template:generate
    #     end # namespace packer:template
end # namespace packer

# ###########   toto   ###########
# desc "toto"
# task :toto do |t|
#     info "#{t.comment}"
#     list_items("packer/debian-5.0.10-amd64/scripts/*",
#                {
#                    :only_files => true,
#                    :pattern_include => [
#                                         #                      '^b'
#                                         #                     ],
#                                         # :pattern_exclude => [
#                                         '^r',
#                                         '^v'
#                                        ]
#                })


# end # task toto

task :setup => 'packer:check'

# private
# def select_from_list(text, list, default_idx = 0)
#     puts list.to_yaml
#     answer = ask("=> #{text}", "#{default_idx}")
#     raise SystemExit.new('exiting selection') if answer == '0'
#     raise RangeError.new('Undefined index')   if Integer(answer) >= list.length
#     return list[Integer(answer)]
# end






#=======================================================================
# eof
#
# Local Variables:
# mode: ruby
# End:
