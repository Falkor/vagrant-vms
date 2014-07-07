##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Lun 2014-07-07 18:56 svarrette>
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
	
	###########   check   ###########
	desc "Check availability of the packer command"
	task :check do |t|
		status =  command?('packer') ? green("OK") : red("FAILED")
		info "#{t.comment}.... #{status}"
		error "Unable to find the 'packer' command on your system. See http://www.packer.io/downloads.html for download instructions" unless command?('packer')
	end # task check 



    #.....................
    namespace :template do

        ###########   template:generate   ###########
        desc "Generate a new template using veewee-to-packer"
        task :generate do |t|
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
                run %{
                  veewee-to-packer -o #{output_dir} #{VEEWEE_TEMPLATE_DIR}/#{template}/definition.rb
                  packer fix #{output_dir}/template.json > #{output_dir}/#{output_dir}.json
                }
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
