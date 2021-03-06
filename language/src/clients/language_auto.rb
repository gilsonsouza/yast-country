# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2012 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# Autoinstallation client for language setting
# Author	: Jiri Suchomel <jsuchome@suse.cz>
#
# $Id$
module Yast
  class LanguageAutoClient < Client
    def main
      Yast.import "Language"
      Yast.import "Console"
      Yast.import "Wizard"

      @ret = nil
      @func = ""
      @param = {}

      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.convert(
            WFM.Args(1),
            :from => "any",
            :to   => "map <string, any>"
          )
        end
      end

      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)

      if @func == "Change"
        Wizard.CreateDialog
        Wizard.HideAbortButton

        @ret = WFM.CallFunction(
          "select_language",
          [{ "enable_back" => true, "enable_next" => true }]
        )

        Wizard.CloseDialog
      elsif @func == "Import"
        @ret = Language.Import(@param)
      elsif @func == "Summary"
        @ret = Language.Summary
      elsif @func == "Reset"
        Language.Import(
          {
            "language"  => Language.language_on_entry,
            "languages" => Language.languages_on_entry
          }
        )
        Language.ExpertSettingsChanged = false
        @ret = {}
      elsif @func == "Read"
        @ret = Language.Read(true)
      elsif @func == "Export"
        @ret = Language.Export
      elsif @func == "Write"
        Console.SelectFont(Language.language)
        Console.Save
        @ret = Language.Save
      # Return if configuration  was changed
      # return boolean
      elsif @func == "GetModified"
        @ret = Language.Modified
      # Set all modified flags
      # return boolean
      elsif @func == "SetModified"
        Language.ExpertSettingsChanged = true # hook (no general 'modified' variable)
        @ret = true
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("language auto finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret)
    end
  end
end

Yast::LanguageAutoClient.new.main
