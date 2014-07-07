##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Lun 2014-07-07 20:12 svarrette>
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

#.....................
namespace :packer do

    ###########   build   ###########
    desc "Build a Vagrant image from a previously generated template"
    task :build do |t|
        info "#{t.comment}"
        list = { 0 => 'Exit' }
        index = 1
        raw_list = {}
        Dir["#{TOP_SRCDIR}/packer/*"].each do |dir|
            if File.directory?(dir)
                entry = File.basename(dir)
                json = Dir.glob("#{dir}/*.json")
                next if json.empty?
                list[index] = entry
                raw_list[entry] = json
                index += 1
            end
        end
        #puts raw_list.inspect
        box = select_from_list("Select the Vagrant box to build using packer", list)
        info "about to build the box '#{box}' using packer"
        really_continue?
        Dir.chdir("#{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/#{box}") do
            raw_list[box].each do |jf|
                json = File.basename("#{jf}")
                info "patching JSON file '#{json}'"
                packer_config = JSON.parse( IO.read( json) )
                packer_config['provisioners'].each do |p|
                    puts p['override'].to_yaml
					next unless p['override']
                    [ 'virtualbox', 'vmware' ].each do |os|
						#next unless p['override'][ "#{os}" ]
                        #ap p['override'][ os ]
						#puts "=> patching p['override']['#{os}-iso']"
						if p['override'][ os ]
							p['override'][ "#{os}-iso" ] = p['override'].delete os
						end 
                        #p[:override][":#{os}-iso"] = p[:override].delete os if p[:override][ os.to_sym ]
						#ap p['override']
						#exit 1
                    end
                end
				# Now store the new json
				File.open(json,"w") do |f|
					f.write JSON.pretty_generate(packer_config)
				end 
				run %{
                   #pwd
                   packer build -only=virtualbox-iso #{json}
                }
            end
        end

    end # task build



    ###########   check   ###########
    desc "Check availability of the packer command"
    task :check do |t|
        status =  command?('packer') ? green("OK") : red("FAILED")
        info "#{t.comment}.... #{status}"
        error "Unable to find the 'packer' command on your system. See http://www.packer.io/downloads.html for download instructions" unless command?('packer')
    end # task check


    #.....................
    namespace :template do

        ###########   clean   ###########
        desc "Clean all the generated templates"
        task :clean do |t|
            info "#{t.comment}"
            run %{
                rm -rf #{TOP_SRCDIR}/#{PACKER_TEMPLATE_DIR}/*
            }
        end # task packer:template:clean

        ###########   template:generate   ###########
        desc "Generate a new template using veewee-to-packer"
        task :generate => [ 'packer:check' ] do |t|
            info "List of supported Operating systems"
            list = { 0 => 'Exit' }
            index = 1
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
            os_list.each do |e|
                list[index] = e
                index+=1
            end
            os = select_from_list("Select a OS index from the list", list, 3)
            info "List of supported version for the #{os} OS"
            version_list = raw_list.select { |e| e =~ /^#{os}/ }
            list = Hash[version_list.each_with_index.map { |value, index| [index+1, value] }]
            list[0] = 'Exit'
            template = select_from_list("Select a version index from the list", list)
            output_dir = 'packer/' + template.gsub(/-netboot/, '').downcase
            if File.directory?("#{output_dir}")
                warn "the directory #{output_dir} already exists"
            else
                jsonfile = "#{output_dir}/#{File.basename output_dir}.json"
                run %{
                  veewee-to-packer -o #{output_dir} #{VEEWEE_TEMPLATE_DIR}/#{template}/definition.rb
                  packer fix #{output_dir}/template.json > #{jsonfile}
                  rm -f #{output_dir}/template.json
                }
                # info "patching JSON file '#{jsonfile}'"
                # packer_config = JSON.parse( IO.read( jsonfile) )

                # packer_config[]
                # ap packer_config
            end
        end # task packer:template:generate
    end # namespace packer:template
end # namespace packer

task :setup => 'packer:check'

private
def select_from_list(text, list, default_idx = 0)
    puts list.to_yaml
    answer = ask("=> #{text}", "#{default_idx}")
    raise SystemExit.new('exiting selection') if answer == '0'
    raise RangeError.new('Undefined index')   if Integer(answer) >= list.length
    return list[Integer(answer)]
end






#=======================================================================
# eof
#
# Local Variables:
# mode: ruby
# End:
