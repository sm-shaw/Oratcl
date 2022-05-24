# oralob:
# Process lob commands.
#
# RCS: @(#) $Id: oralob.tcl,v 1.14 2016/03/29 16:54:23 tmh Exp $
#
# Copyright (c) 2000 Todd M. Helfter
#

namespace eval oratcl {

	variable oralob
	variable plsql
	variable loblst {}
	variable lobidx 0

	#set oralob(script) [info script]
	set oralob(oratcl_ok) 0
	set oralob(oratcl_error) 1

	set plsql(clob_read) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			DBMS_LOB.READ(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(blob_read) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			DBMS_LOB.READ(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(clob_write) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.WRITE(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(blob_write) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.WRITE(lob_loc, :lob_amt, :lob_pos, :lob_str); \
		end; \
	}

	set plsql(clob_length) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			:rlen := DBMS_LOB.GETLENGTH(lob_loc); \
		end; \
	}

	set plsql(blob_length) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid; \
			:rlen := DBMS_LOB.GETLENGTH(lob_loc); \
		end; \
	}

	set plsql(clob_trim) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.TRIM(lob_loc, :lob_len); \
		end; \
	}

	set plsql(blob_trim) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.TRIM(lob_loc, :lob_len); \
		end; \
	}

	set plsql(clob_erase) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.ERASE(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(blob_erase) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			DBMS_LOB.ERASE(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(clob_substr) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:sub_str := DBMS_LOB.SUBSTR(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(blob_substr) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:sub_str := DBMS_LOB.SUBSTR(lob_loc, :lob_amt, :lob_off); \
		end; \
	}

	set plsql(clob_instr) { \
		declare \
			lob_loc CLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:ins_pos := DBMS_LOB.INSTR(lob_loc, :lob_ptn, :lob_off, :lob_nth); \
		end; \
	}

	set plsql(blob_instr) { \
		declare \
			lob_loc BLOB; \
		begin \
			select %s into lob_loc from %s where rowid = :rid for update; \
			:ins_pos := DBMS_LOB.INSTR(lob_loc, :lob_ptn, :lob_off, :lob_nth); \
		end; \
	}

	set plsql(clob_append) { \
		declare \
			lob_loc1 CLOB; \
			lob_loc2 CLOB; \
		begin \
			select %s into lob_loc1 from %s where rowid = :rid1 for update; \
			select %s into lob_loc2 from %s where rowid = :rid2; \
			DBMS_LOB.APPEND(lob_loc1, lob_loc2); \
		end; \
	}

	set plsql(blob_append) { \
		declare \
			lob_loc1 BLOB; \
			lob_loc2 BLOB; \
		begin \
			select %s into lob_loc1 from %s where rowid = :rid1 for update; \
			select %s into lob_loc2 from %s where rowid = :rid2; \
			DBMS_LOB.APPEND(lob_loc1, lob_loc2); \
		end; \
	}

	set plsql(clob_compare) { \
		declare \
			lob_loc1 CLOB; \
			lob_loc2 CLOB; \
		begin \
			select %s into lob_loc1 from %s where rowid = :rid1 for update; \
			select %s into lob_loc2 from %s where rowid = :rid2; \
			:lob_cmp := DBMS_LOB.COMPARE(lob_loc1, lob_loc2, :lob_amt, :lob_of1, :lob_of2); \
		end; \
	}

	set plsql(blob_compare) { \
		declare \
			lob_loc1 BLOB; \
			lob_loc2 BLOB; \
		begin \
			select %s into lob_loc1 from %s where rowid = :rid1 for update; \
			select %s into lob_loc2 from %s where rowid = :rid2; \
			:lob_cmp := DBMS_LOB.COMPARE(lob_loc1, lob_loc2, :lob_amt, :lob_of1, :lob_of2); \
		end; \
	}
}

#
#  parse lob args.
#
proc ::oratcl::parse_lob_args {args} {

	set argv [lindex $args 0]
	set argc [llength $argv]
	for {set argx 0} {$argx < $argc} {incr argx} {
		set option [lindex $argv $argx]
		if {[incr argx] >= $argc} {
			set err_txt "oralob: value parameter to $option is missing."
			return -code error $err_txt 
		}
		set value [lindex $argv $argx]
                if {[regexp ^- $option]} {
                        set index [string range $option 1 end]
                        set ::oratcl::oralob($index) $value
                }
	}		
}

proc oralob {command handle args} {

	global errorInfo

	foreach idx [list rowid table column pattern datavariable] {
		set ::oratcl::oralob($idx) {}
	}
	foreach idx [list start stop length start1 start2] {
		set ::oratcl::oralob($idx) 0
	}
	foreach idx [list nth] {
		set ::oratcl::oralob($idx) 1
	}

	set tcl_res {}

	set cm(alloc)	[list ::oratcl::lob_alloc $handle $args]
	set cm(free) 	[list ::oratcl::lob_free $handle]
	set cm(read)	[list ::oratcl::lob_read $handle $args]
	set cm(write)	[list ::oratcl::lob_write $handle $args]
	set cm(length)	[list ::oratcl::lob_length $handle]
	set cm(trim)	[list ::oratcl::lob_trim $handle $args]
	set cm(erase)	[list ::oratcl::lob_erase $handle $args]
	set cm(substr)	[list ::oratcl::lob_substr $handle $args]
	set cm(instr)	[list ::oratcl::lob_instr $handle $args]
	set cm(append)	[list ::oratcl::lob_append $handle [lindex $args 0]]
	set cm(compare)	[list ::oratcl::lob_compare $handle [lindex $args 0] [lrange $args 1 end]]

	if {! [info exists cm($command)]} {
		 set err_txt "oralob: unknown command option '$command'"
		 return -code error $err_txt 
	}

	set tcl_rc [catch {eval $cm($command)} tcl_res]
	if {$tcl_rc} {
		return -code error "$tcl_res"
	}

	return $tcl_res
}

#
#  allocate a lob identifier
#
proc ::oratcl::lob_alloc {handle args} {

	global errorInfo

	variable lobidx 
	variable loblst
	variable oralob

	set fn alloc

	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	if {[string is space $oralob(rowid)]} {
		set err_txt "oralob $fn: invalid rowid value."
		return -code error $err_txt
	}

	if {[string is space $oralob(table)]} {
		set err_txt "oralob $fn: invalid table value."
		return -code error $err_txt
	}

	if {[string is space $oralob(column)]} {
		set err_txt "oralob $fn: invalid column value."
		return -code error $err_txt
	}

	set tcl_rc [catch {orainfo loginhandle $handle} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	set loghandle $tcl_res

	set tcl_rc [catch {oradesc $loghandle $oralob(table)} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	set autotype {}
	foreach row $tcl_res {
		if {[string equal [lindex $row 0] [string toupper $oralob(column)]]} {
			set autotype [lindex $row 2]
			::break
		}
	}

	if {[string is space $autotype]} {
		set err_txt "oralob $fn: error column '$oralob(column)' not found."
		return -code error $err_txt
	}

	if {[string equal $autotype CLOB]} {
		set lobtype clob
	} elseif {[string equal $autotype BLOB]} {
		set lobtype blob
	} else {
		set err_txt "oralob $fn: error unsuported lob type '$autotype'."; \
		return -code error $err_txt \
	}

	set pl [format $::oratcl::plsql(${lobtype}_length) $oralob(column) $oralob(table)]

	set tcl_rc [catch {oraplexec $handle \
				     $pl \
				     :rid $oralob(rowid) \
				     :rlen {} } \
			  tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	set lob oralob.$lobidx
	incr lobidx
	set loblst($lob) [list $handle $oralob(table) $oralob(column) $oralob(rowid) $lobtype]

	return $lob
}

#
#  free a lob identifier
#
proc ::oratcl::lob_free {handle} {

	variable oralob
	variable loblst

	set fn free

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: handle $handle not open."
		return -code error $err_txt
	}

	set tcl_rc [catch {unset loblst($handle)} tcl_res]
	if {$tcl_rc} {
		set err_txt "oralob $fn: $tcl_res"
		return -code error $err_txt
	}

	return -code ok $oralob(oratcl_ok)
}


#
#  read the contents of a lob field.
#
proc ::oratcl::lob_read {handle args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn read

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: handle $handle not open."
		return -code error $err_txt
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	upvar 2 $oralob(datavariable) read_res
	set read_res {}

	set tcl_rc [catch {::oratcl::lob_length $handle} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}
	set len $tcl_res

	set siz [oraconfig $stm lobpsize]

	# save original bindsize setting.
	set bsz [oraconfig $stm bindsize]
	oraconfig $stm bindsize [expr {$siz * 2}]

	set tcl_err 0
	set err_txt {}

	set pos 1
	while {$pos <= $len} {

		set pl [format $::oratcl::plsql(${lobtype}_read) $column $table]

		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :lob_amt $siz \
					     :lob_pos $pos \
					     :lob_str {} } \
				  tcl_res] 
		if {$tcl_rc} {
			set tcl_err 1
			set info $errorInfo
			set err_txt "oralob $fn: [oramsg $handle error] $info"
			::break
		}
		orafetch $stm -datavariable tcl_res
		set out [lindex $tcl_res 3]

		if {[string equal $lobtype blob]} {
			set out [binary format H* $out]
		}

		append read_res $out
		set amt [string length $out]
		incr pos $amt
	}

	catch {oraconfig $stm bindsize $bsz}

	if {$tcl_err} {
		return -code error -errorinfo $err_txt
	}

	return -code ok $oralob(oratcl_ok)
}

#
#  write data to a lob field.
#
proc ::oratcl::lob_write {handle args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn write

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: handle $handle not open."
		return -code error $err_txt
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	upvar 2 $oralob(datavariable) data
	set tot [string length $data]

	set siz [oraconfig $stm lobpsize]

	# save original bindsize setting.
	set bsz [oraconfig $stm bindsize]
	oraconfig $stm bindsize [expr {$siz * 2}]

	set tcl_rc [catch {::oratcl::lob_trim $handle} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	set tcl_err 0
	set err_txt {}

	set pos 1
	while {$pos <= $tot} {
		set str [string range $data [expr {$pos - 1}] [expr {$pos - 2 + $siz}] ]
		set amt [string length $str]

		if {[string equal $lobtype blob]} {
			binary scan $str H* str
		}

		set pl [format $::oratcl::plsql(${lobtype}_write) $column $table]
		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :lob_amt $amt \
					     :lob_pos $pos \
					     :lob_str $str } \
				  tcl_res]
		if {$tcl_rc} {
			set tcl_err 1
			set info $errorInfo
			set err_txt "oralob $fn: [oramsg $handle error] $info"
			::break
		}

		incr pos $amt
	}

	catch {oraconfig $stm bindsize $bsz}

	if {$tcl_err} {
		return -code error -errorinfo $err_txt
	}

	return -code ok $oralob(oratcl_ok)
}

#
#  return then length of a lob field.
#
proc ::oratcl::lob_length {handle} {

	global errorInfo
	variable loblst

	set fn length

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: handle $handle not open."
		return -code error $err_txt
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	set pl [format $::oratcl::plsql(${lobtype}_length) $column $table]
	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :rlen {} } \
			  tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}
	orafetch $stm -datavariable tcl_res
	return [lindex $tcl_res 1]
}

#
#  trim a lob field.
#
proc ::oratcl::lob_trim {handle args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn trim

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: handle $handle not open."
		return -code error $err_txt
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	set pl [format $::oratcl::plsql(${lobtype}_trim) $column $table]
	set tcl_rc [catch {oraplexec $stm \
			             $pl \
			             :rid $rowid \
			             :lob_len $oralob(length)}]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	return -code ok $oralob(oratcl_ok)
}

#
#  erase a lob field.
#
proc ::oratcl::lob_erase {handle args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn erase

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: handle $handle not open."
		return -code error $err_txt
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	if {![string is integer $oralob(start)] || $oralob(start) < 0} {
		set err_txt "oralob $fn: -start value '$oralob(start)' must be a non negative integer."
		return -code error $err_txt
	}

	if {![string is integer $oralob(stop)] || $oralob(stop) < 0} {
		set err_txt "oralob $fn: -stop value '$oralob(stop)' must be a non negative integer."
		return -code error $err_txt
	}

	if {$oralob(stop) < $oralob(start)} {
		set err_txt "oralob $fn: -stop value '$oralob(stop)' may not be less than -start value '$oralob(start)'."
		return -code error $err_txt
	}

	set amt [expr {$oralob(stop) - $oralob(start) + 1}]
	set off [expr {$oralob(start) + 1}]

	set pl [format $::oratcl::plsql(${lobtype}_erase) $column $table]

	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :lob_amt $amt \
				     :lob_off $off}]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	return -code ok $oralob(oratcl_ok)
}

#
#  substr a lob field.
#
proc ::oratcl::lob_substr {handle args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn substr

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: lob handle '$handle' not open."
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	upvar 2 $oralob(datavariable) sub_res
	set sub_res {}

	if {![string is integer $oralob(start)] || $oralob(start) < 0} {
		set err_txt "oralob $fn: -start value '$oralob(start)' must be a non negative integer."
		return -code error $err_txt
	}

	if {![string is integer $oralob(stop)] || $oralob(stop) < 0} {
		set err_txt "oralob $fn: -stop value '$oralob(stop)' must be a non negative integer."
		return -code error $err_txt
	}

	if {$oralob(stop) < $oralob(start)} {
		set err_txt "oralob $fn: -stop value '$oralob(stop)' may not be less than -start value '$oralob(start)'."
		return -code error $err_txt
	}

	set tcl_rc [catch {::oratcl::lob_length $handle} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}

	if {$oralob(stop) > $tcl_res} {
		set oralob(stop) $tcl_res
	}

	set rem [expr {$oralob(stop) - $oralob(start) + 1}]
	set off [expr {$oralob(start) + 1}]

	set siz [oraconfig $stm lobpsize]

	# save original bindsize setting.
	set bsz [oraconfig $stm bindsize]
	oraconfig $stm bindsize [expr {$siz * 2}]

	set pl [format $::oratcl::plsql(${lobtype}_substr) $column $table]

	while {$rem > 0} {

		if {$rem > $siz} {
			set par $siz
		} else {
			set par $rem
		}

		set tcl_rc [catch {oraplexec $stm \
					     $pl \
					     :rid $rowid \
					     :sub_str {} \
					     :lob_amt $par \
					     :lob_off $off} \
				  tcl_res]
		if {$tcl_rc} {
			set info $errorInfo
			set err_txt "oralob $fn: [oramsg $handle error] $info"
			return -code error $err_txt
		}
		orafetch $stm -datavariable tcl_res

		set rem [expr {$rem - $par}]
		incr off $par
	
		set out [lindex $tcl_res 1]
		if {[string equal $lobtype blob]} {
			set out [binary format H* $out]
		}
		append sub_res $out
	}

	catch {oraconfig $stm bindsize $bsz}

	return -code ok $oralob(oratcl_ok)
}

#
#  instr a lob field.
#
proc ::oratcl::lob_instr {handle args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn instr

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	#
	# Test that lob handle is valid.
	#
	if {![info exists loblst($handle)]} {
		set err_txt "oralob $fn: lob handle '$handle' not open."
		return -code error $err_txt
	}

	set stm [lindex $loblst($handle) 0]
	set table [lindex $loblst($handle) 1]
	set column [lindex $loblst($handle) 2]
	set rowid [lindex $loblst($handle) 3]
	set lobtype [lindex $loblst($handle) 4]

	#
	#  Test that pattern will fit in existing configuration
	#
	if {[string length $oralob(pattern)] > [oraconfig $stm lobpsize] 
	 || [string length $oralob(pattern)] > [oraconfig $stm bindsize] * 2} {
		set err_txt "oralob $fn: -pattern value too large for bindsize or lobpsize."
		return -code error $err_txt
	}

	if {![string is integer $oralob(start)] || $oralob(start) < 0} {
		set err_txt "oralob $fn: -start value '$oralob(start)' must be a non negative integer."
		return -code error $err_txt
	}

	if {![string is integer $oralob(nth)] || $oralob(nth) < 1} {
		set err_txt "oralob $fn: -nth value '$oralob(nth)' must be a positive integer."
		return -code error $err_txt
	}

	set offset [expr {$oralob(start) + 1}]

	if {[string equal $lobtype blob]} {
		binary scan $oralob(pattern) H* oralob(pattern)
	}

	set pl [format $::oratcl::plsql(${lobtype}_instr) $column $table]
	set tcl_rc [catch {oraplexec $stm \
				     $pl \
				     :rid $rowid \
				     :ins_pos {} \
				     :lob_ptn $oralob(pattern) \
				     :lob_off $offset \
				     :lob_nth $oralob(nth)} \
			  tcl_res] 
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle error] $info"
		return -code error $err_txt
	}
	orafetch $stm -datavariable tcl_res

	return -code ok [expr [lindex $tcl_res 1] - 1]
}

#
#  append a lob field to another lob field.
#
proc ::oratcl::lob_append {handle1 handle2} {

	global errorInfo
	variable loblst
	variable oralob

	set fn append

	#
	# Test that lob handle is valid.
	#
	if {![info exists loblst($handle1)]} {
		set err_txt "oralob $fn: lob handle '$handle1' not open."
		return -code error $err_txt
	}

	#
	# Test that lob handle is valid.
	#
	if {![info exists loblst($handle2)]} {
		set err_txt "oralob $fn: lob handle '$handle2' not open."
		return -code error $err_txt
	}

	set stm1 [lindex $loblst($handle1) 0]
	set table1 [lindex $loblst($handle1) 1]
	set column1 [lindex $loblst($handle1) 2]
	set rowid1 [lindex $loblst($handle1) 3]
	set lobtype1 [lindex $loblst($handle1) 4]

	set stm2 [lindex $loblst($handle2) 0]
	set table2 [lindex $loblst($handle2) 1]
	set column2 [lindex $loblst($handle2) 2]
	set rowid2 [lindex $loblst($handle2) 3]
	set lobtype2 [lindex $loblst($handle2) 4]

	if {![string equal $lobtype1 $lobtype2]} {
		set err_txt "oralob $fn: lobs must be of the same type."
		return -code error $err_txt
	}

	set pl [format $::oratcl::plsql(${lobtype1}_append) $column1 $table1 $column2 $table2]
	set tcl_rc [catch {oraplexec $stm1 \
				     $pl \
				     :rid1 $rowid1 \
				     :rid2 $rowid2} \
			  tcl_res] 
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle1 error] $info"
		return -code error $err_txt
	}

	return -code ok $oralob(oratcl_ok)
}

#
#  compare two lob fields field.
#
proc ::oratcl::lob_compare {handle1 handle2 args} {

	global errorInfo
	variable loblst
	variable oralob

	set fn compare

	# process arguements
	set tcl_rc [catch {eval ::oratcl::parse_lob_args $args} tcl_res]
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: $info"
		return -code error $err_txt
	}

	#
	# Test that lob handle is valid.
	#
	if {![info exists loblst($handle1)]} {
		set err_txt "oralob $fn: lob handle '$handle1' not open."
		return -code error $err_txt
	}

	#
	# Test that lob handle is valid.
	#
	if {![info exists loblst($handle2)]} {
		set err_txt "oralob $fn: lob handle '$handle2' not open."
		return -code error $err_txt
	}

	set stm1 [lindex $loblst($handle1) 0]
	set table1 [lindex $loblst($handle1) 1]
	set column1 [lindex $loblst($handle1) 2]
	set rowid1 [lindex $loblst($handle1) 3]
	set lobtype1 [lindex $loblst($handle1) 4]

	set stm2 [lindex $loblst($handle2) 0]
	set table2 [lindex $loblst($handle2) 1]
	set column2 [lindex $loblst($handle2) 2]
	set rowid2 [lindex $loblst($handle2) 3]
	set lobtype2 [lindex $loblst($handle2) 4]

	if {![string equal $lobtype1 $lobtype2]} {
		set err_txt "oralob $fn: lobs must be of the same type."
		return -code error $err_txt
	}

	if {![string is integer $oralob(start1)] || $oralob(start1) < 0} {
		set err_txt "oralob $fn: -start1 value '$oralob(start1)' must be a non negative integer."
		return -code error $err_txt
	}

	if {![string is integer $oralob(start2)] || $oralob(start2) < 0} {
		set err_txt "oralob $fn: -start2 value '$oralob(start2)' must be a non negative integer."
		return -code error $err_txt
	}

	if {![string is integer $oralob(length)]} {
		set err_txt "oralob $fn: -length value '$oralob(length)' must be a positive integer."
		return -code error $err_txt
	}

	# handle some default situation : no length specified 
	if {$oralob(length) < 1} {

		# get length of lob1
		set tcl_rc [catch {::oratcl::lob_length $handle1} tcl_res]
		if {$tcl_rc} {
			set info $errorInfo
			set err_txt "oralob $fn: [oramsg $handle1 error] $info"
			return -code error $err_txt
		}
		set han1_len $tcl_res
		set han1_siz [expr {$han1_len - $oralob(start1)}]

		set tcl_rc [catch {::oratcl::lob_length $handle2} tcl_res]
		if {$tcl_rc} {
			set info $errorInfo
			set err_txt "oralob $fn: [oramsg $handle1 error] $info"
			return -code error $err_txt
		}
		set han2_len $tcl_res
		set han2_siz [expr {$han1_len - $oralob(start2)}]

		if {$han1_siz != $han2_siz} {
			return -code ok 1
		}
		set oralob(length) $han1_siz
	}

	incr oralob(start1)
	incr oralob(start2)

	set pl [format $::oratcl::plsql(${lobtype1}_compare) $column1 $table1 $column2 $table2]
	set tcl_rc [catch {oraplexec $stm1 \
				     $pl \
				     :rid1 $rowid1 \
				     :rid2 $rowid2 \
				     :lob_cmp {} \
				     :lob_amt $oralob(length) \
				     :lob_of1 $oralob(start1) \
				     :lob_of2 $oralob(start2)} \
			  tcl_res] 
	if {$tcl_rc} {
		set info $errorInfo
		set err_txt "oralob $fn: [oramsg $handle1 error] $info"
		return -code error $err_txt
	}
	orafetch $stm1 -datavariable tcl_res

	return -code ok [lindex $tcl_res 2]
}
