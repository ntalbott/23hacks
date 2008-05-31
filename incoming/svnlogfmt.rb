#!/usr/local/bin/ruby

require 'optparse'
require 'ostruct'
require 'rubygems'
require 'active_support'
require 'date'
require File.join(File.dirname(__FILE__), 'clients')

options = OpenStruct.new(:start_adjust => 0,
                         :end_adjust => 0,
                         :verbose => false)

OptionParser.new do |opts|
  opts.on("-c[=CLIENT]", "--client[=CLIENT]", String) do |val|
    options.client     = CLIENTS[val][:client]
    options.user       = CLIENTS[val][:user]
    options.repository = CLIENTS[val][:repository]
    options.trac       = CLIENTS[val][:trac]
    options.start_adjust = CLIENTS[val][:start_adjust] if CLIENTS[val].has_key?(:start_adjust)
    options.end_adjust   = CLIENTS[val][:end_adjust]   if CLIENTS[val].has_key?(:end_adjust)
  end
  opts.on("--start=DAYSAGO", Integer) do |val|
    options.start_adjust = val
  end
  opts.on("--end=DAYSAGO", Integer) do |val|
    options.end_adjust = val
  end
  opts.on("-v","--[no-]verbose", "Include date of each entry") do |val|
    options.verbose = true
  end
end.parse!

STDERR.puts options.to_s

date_format = "%d-%b-%Y"
title_date_format = "%Y%m%d"
pattern = Regexp.new("^r(\\d+) [|] (?:#{options.user.join('|')}) [|] (\\d{4}-\\d\\d-\\d\\d \\d\\d:\\d\\d:\\d\\d)")
svk_ignorable = /r\d+@[-a-z]+:\s+\w+ [|] (\d{4}-\d\d-\d\d \d\d:\d\d:\d\d -\d{4})/i

# startdate = Date.today - options.start_days_ago
# enddate = Date.today - options.end_days_ago
startdate = 1.week.ago.beginning_of_week.to_date + options.start_adjust
enddate = Time.now.beginning_of_week.to_date + options.end_adjust
date_range = startdate .. (enddate-1)

output = <<"HEADING"
<html><head><title>
#{options.client}: #{[:begin,:end].map{|m|date_range.send(m).strftime(title_date_format)}*'/'}
</title></head><body style='font-family: Helvetica; font-size: 12pt;'>
<h1>#{options.client}</h1>
<h2>From #{date_range.begin.strftime date_format} to #{date_range.end.strftime date_format}</h2>
<p style='font-family: Helvetica; font-size: 12pt; text-indent:-2em; padding-left:2em;'>Changesets:<br />
HEADING

capturing = false
msg = []
timestamp = ''
cmd = "svn log -r '{#{startdate}}:{#{enddate}}' #{options.repository}"
puts cmd if options.verbose
IO.popen(cmd) do |log|
  log.each do |line|

    case line
    when pattern
      next unless date_range.include? Date.parse($2)
      if options.trac
        output << "<a href='#{options.trac}/#{$1}'>[#{$1}]</a>&nbsp;"
      else
        output << "[#{$1}]&nbsp;"
      end
      capturing = true            # need to get the lines of the log comment
      timestamp = "#{$2} ".gsub(/\s+/,'&nbsp;') if options.verbose
      msg << ''
    when /^-+$/
      capturing = false
      msg.pop if msg.last && msg.last.empty? # skip an empty comment
      output << timestamp << msg.join("\n").gsub("\n\n","\n") unless msg.empty?
      timestamp = ''
      msg = []
    else
      if capturing
        # small edits that don't need to be on invoice are "(typically in parens)"
        if ! line.empty? && line.strip !~ /\A(?:\(.*\))?\z/ && line !~ svk_ignorable
          msg[-1] << line.sub(/$/,'<br />')
        elsif options.verbose && line =~ svk_ignorable
          timestamp = "#{$1} ".gsub(/\s+/, '&nbsp;')
        end
      end
    end
  end
end

output << "\n</p>\n</body></html>\n"

STDOUT.write output

__END__
# Things to notice:
# * the first message may be from a date that immediately preceeds the
#   requested range
# * svk has additional verbiage in the log message related to the local
#   revision and user that may not be relevant to the respository (or the
#   client)

=begin svn
rab:trunk $ svn log -r '{2006-11-20}:{2006-11-27}'

------------------------------------------------------------------------
r600 | rbiedenharn | 2006-11-19 23:16:47 -0500 (Sun, 19 Nov 2006) | 1 line

fix css property
------------------------------------------------------------------------
r601 | rbiedenharn | 2006-11-20 09:33:50 -0500 (Mon, 20 Nov 2006) | 1 line

add a timestamp to the RankImporter#alexa output (to be run from cron)
------------------------------------------------------------------------
r602 | rbiedenharn | 2006-11-20 14:18:16 -0500 (Mon, 20 Nov 2006) | 1 line

all my interests tab for dashboard
------------------------------------------------------------------------
r603 | bwagaman | 2006-11-20 14:37:50 -0500 (Mon, 20 Nov 2006) | 1 line

allow test drive account registration
------------------------------------------------------------------------
r604 | bwagaman | 2006-11-20 16:51:11 -0500 (Mon, 20 Nov 2006) | 1 line

fix account registration
------------------------------------------------------------------------
r605 | bwagaman | 2006-11-20 17:06:22 -0500 (Mon, 20 Nov 2006) | 1 line

fixed up admin panel
------------------------------------------------------------------------
r606 | bwagaman | 2006-11-20 17:15:45 -0500 (Mon, 20 Nov 2006) | 1 line

add registration links
------------------------------------------------------------------------
r607 | bwagaman | 2006-11-21 11:15:43 -0500 (Tue, 21 Nov 2006) | 1 line

small changes
------------------------------------------------------------------------
r608 | bwagaman | 2006-11-21 12:43:02 -0500 (Tue, 21 Nov 2006) | 1 line

my interests
------------------------------------------------------------------------
r609 | bwagaman | 2006-11-21 14:38:51 -0500 (Tue, 21 Nov 2006) | 1 line

buttons, topnav and google search + sbc
------------------------------------------------------------------------
r610 | rbiedenharn | 2006-11-21 15:13:44 -0500 (Tue, 21 Nov 2006) | 1 line

minor tweaks
------------------------------------------------------------------------
r611 | rbiedenharn | 2006-11-21 15:30:04 -0500 (Tue, 21 Nov 2006) | 1 line

get SBC clickable letters for dashboard
------------------------------------------------------------------------
r612 | bwagaman | 2006-11-21 15:50:30 -0500 (Tue, 21 Nov 2006) | 1 line

minor changes
------------------------------------------------------------------------
r613 | bwagaman | 2006-11-21 15:54:30 -0500 (Tue, 21 Nov 2006) | 1 line

oops
------------------------------------------------------------------------
r614 | rbiedenharn | 2006-11-21 16:53:46 -0500 (Tue, 21 Nov 2006) | 1 line

update account_controller_test; simplify sbc letters on dashboard
------------------------------------------------------------------------
r615 | bwagaman | 2006-11-21 17:40:48 -0500 (Tue, 21 Nov 2006) | 1 line

more on interests
------------------------------------------------------------------------
r616 | bwagaman | 2006-11-22 15:59:43 -0500 (Wed, 22 Nov 2006) | 1 line

handful of changes
------------------------------------------------------------------------
r617 | bwagaman | 2006-11-22 17:03:11 -0500 (Wed, 22 Nov 2006) | 1 line

new flash animation
------------------------------------------------------------------------
r618 | bwagaman | 2006-11-22 18:14:14 -0500 (Wed, 22 Nov 2006) | 1 line

fixed up my interests a little bit better
------------------------------------------------------------------------
r619 | rbiedenharn | 2006-11-22 21:50:11 -0500 (Wed, 22 Nov 2006) | 1 line

use login_token properly even from !IndexController
------------------------------------------------------------------------
r620 | rbiedenharn | 2006-11-22 22:39:22 -0500 (Wed, 22 Nov 2006) | 1 line

fix passing of privacy status to import process
------------------------------------------------------------------------
r621 | rbiedenharn | 2006-11-22 23:00:07 -0500 (Wed, 22 Nov 2006) | 1 line

give rankameter a lower-bound of 10
------------------------------------------------------------------------
r622 | rbiedenharn | 2006-11-22 23:28:58 -0500 (Wed, 22 Nov 2006) | 1 line

avoid a new empty ranking clobbering an existing one
------------------------------------------------------------------------
r623 | rbiedenharn | 2006-11-22 23:58:56 -0500 (Wed, 22 Nov 2006) | 1 line

replace "my interests" with "all my interests" on the dashboard
------------------------------------------------------------------------
=end

=begin svk
rab:Stylepath/svk $ svn log -r {2007-02-05}:{2007-02-12} http://agileconsultingllc.com/svn/stylepath
------------------------------------------------------------------------
r11 | agile-rob | 2007-02-03 02:33:32 -0500 (Sat, 03 Feb 2007) | 3 lines

 r808@rob-biedenharns-computer:  rab | 2007-02-03 02:33:11 -0500
 acts_as_authenticated

------------------------------------------------------------------------
r12 | agile-rob | 2007-02-06 20:00:38 -0500 (Tue, 06 Feb 2007) | 3 lines

 r834@rob-biedenharns-computer:  rab | 2007-02-06 20:00:26 -0500
 new Rails 1.2.2; add Category; simply_helpful plugin

------------------------------------------------------------------------
r13 | agile-rob | 2007-02-07 20:03:25 -0500 (Wed, 07 Feb 2007) | 3 lines

 r836@rob-biedenharns-computer:  rab | 2007-02-06 21:23:26 -0500
 User.last_loggedin_at (but tests are failing due to authentication)

------------------------------------------------------------------------
r14 | agile-rob | 2007-02-07 20:03:37 -0500 (Wed, 07 Feb 2007) | 3 lines

 r837@rob-biedenharns-computer:  rab | 2007-02-07 19:52:19 -0500
 show product counts; change amazon.com page used in products/browse; recognize wider set of URLs having an ASIN

------------------------------------------------------------------------
r15 | agile-rob | 2007-02-08 10:08:35 -0500 (Thu, 08 Feb 2007) | 3 lines

 r840@rob-biedenharns-computer:  rab | 2007-02-08 10:08:20 -0500
 customize setup and deployment for my*-production.{yml,rb}

------------------------------------------------------------------------
r16 | agile-rob | 2007-02-11 00:30:26 -0500 (Sun, 11 Feb 2007) | 3 lines

 r842@rob-biedenharns-computer:  rab | 2007-02-09 00:01:27 -0500
 first cut at characteristics

------------------------------------------------------------------------
r17 | agile-rob | 2007-02-11 00:30:48 -0500 (Sun, 11 Feb 2007) | 3 lines

 r843@rob-biedenharns-computer:  rab | 2007-02-11 00:30:20 -0500
 fix after_update_code

------------------------------------------------------------------------
r18 | agile-rob | 2007-02-11 01:19:26 -0500 (Sun, 11 Feb 2007) | 3 lines

 r846@rob-biedenharns-computer:  rab | 2007-02-11 01:19:18 -0500
 show application_revision

------------------------------------------------------------------------

=end
