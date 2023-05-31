* @ValidationCode : Mjo0NjM4ODM3NjI6Q3AxMjUyOjE2ODAwNzEwNzc5MzU6SVRTUzotMTotMTowOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.TEMP.STORE.COMMON(Y.ACTION)
*******************************************************************************************************************
*Company   Name    : APAP
*Developed By      : Temenos Application Management
*Program   Name    : REDO.TEMP.STORE.COMMON
*Author            : ganeshhari@temenos.com
*ODR Number        : PACS00045355-B.16
*------------------------------------------------------------------------------------------------------------------

*Description       : This is the workarround routine for solve the issue during arrangement principal interest change
*                    To store the I_AA.APP.COMMON varibles into the local varibles and local varible to I_AA.APP.COMMON
*Linked With       : N/A
*In  Parameter     : N/A
*Out Parameter     : N/A
*------------------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================

* 31-Mar-2010 - Creation for the issue PACS00045355-B.16 -Authorization of a Change of Installment reversal activity
** 29-03-2023 R22 Auto Conversion 
** 29-03-2023 Skanda R22 Manual Conversion - No changes
*------------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.REDO.TEMP.STORE.COMMON

    GOSUB ASSIGN.COMMON

RETURN

*------------------------------------------------------------------------------------------------------------------
* If Y.ACTION equals to 'STORE' then store all APP.COMMON varibles values to local varible and  Y.ACTION equat to 'RESTORE'
* the local varibles values in to APP.COMMON
*------------------------------------------------------------------------------------------------------------------
ASSIGN.COMMON:

    BEGIN CASE

        CASE Y.ACTION EQ 'STORE'
            GOSUB UPDATE.STORE


        CASE Y.ACTION EQ 'RESTORE'
            GOSUB UPDATE.RESTORE

    END CASE

RETURN
*---------------------------------------------------
UPDATE.STORE:
*---------------------------------------------------

    Y.AA.PROPERTY.CLASS.ID   =   AA$PROPERTY.CLASS.ID
    Y.AA.PROPERTY.CLASS.REC   =    AA$PROPERTY.CLASS.REC
    Y.AA.PRODUCT.ARR   =    AA$PRODUCT.ARR
    Y.AA.RULE.TYPE   =    AA$RULE.TYPE
    Y.AA.MAND   =    AA$MAND
    Y.AA.FIELD.ACTIVITY   =    AA$FIELD.ACTIVITY
    Y.AA.FIELD.DATA.TYPE   =    AA$FIELD.DATA.TYPE
    Y.AA.DATED.ID   =    AA$DATED.ID
    Y.AA.CCY.ID   =    AA$CCY.ID
    Y.AA.OPT.CCY.ID   =    AA$OPT.CCY.ID
    Y.AA.MULTI.PROPERTY   =    AA$MULTI.PROPERTY
    Y.AA.CUST.ID   =    AA$CUST.ID
    Y.AA.ARR.ID   =    AA$ARR.ID
    Y.AA.R.ARRANGEMENT   =    AA$R.ARRANGEMENT
    Y.AA.PROP.EFF.DATE   =    AA$PROP.EFF.DATE
    Y.AA.PROPERTY.ID   =    AA$PROPERTY.ID
    Y.AA.PREV.PROD.PROP.REC   =    AA$PREV.PROD.PROP.REC
    Y.AA.OVERRIDE.LIST   =    AA$OVERRIDE.LIST
    Y.AA.ARR.LINK.TYPE   =    AA$ARR.LINK.TYPE
    Y.AA.ARR.PRODUCT.ID   =    AA$ARR.PRODUCT.ID
    Y.AA.ARR.CURRENCY   =    AA$ARR.CURRENCY
    Y.AA.ARR.CHANGED.FIELDS   =    AA$ARR.CHANGED.FIELDS
    Y.AA.RESERVED7   =    AA$RESERVED7
    Y.AA.PRODUCT.RECORD   =    AA$PRODUCT.RECORD
    Y.AA.PROD.PROP.RECORD   =    AA$PROD.PROP.RECORD
    Y.AA.ARR.PC.ID   =    AA$ARR.PC.ID
    Y.AA.ACTIVITY.ID   =    AA$ACTIVITY.ID
    Y.AA.ACTIVITY.EFF.DATE   =    AA$ACTIVITY.EFF.DATE
    Y.AA.ARRANGEMENT.STATUS   =    AA$ARRANGEMENT.STATUS
    Y.AA.TXN.REFERENCE   =    AA$TXN.REFERENCE
    Y.AA.CURR.ACTION   =    AA$CURR.ACTION
    Y.AA.R.ARRANGEMENT.ACTIVITY   =    AA$R.ARRANGEMENT.ACTIVITY
    Y.AA.XREF.ID.REQD   =    AA$XREF.ID.REQD
    Y.AA.LOCAL.REF.LIST   =    AA$LOCAL.REF.LIST
    Y.AA.ASSOC   =    AA$ASSOC
    Y.AA.F   =    AA$F
    Y.AA.FNO   =    AA$FNO
    Y.AA.N   =    AA$N
    Y.AA.T   =    AA$T
    Y.AA.CHECKFILE   =    AA$CHECKFILE
    Y.AA.RULE.TYPE   =    AA$RULE.TYPE
    Y.AA.ACTIVITY   =    AA$ACTIVITY
    Y.AA.CURR.ACTIVITY   =    AA$CURR.ACTIVITY
    Y.AA.LINKED.ACCOUNT   =    AA$LINKED.ACCOUNT
    Y.AA.NEW.ARRANGEMENT   =    AA$NEW.ARRANGEMENT
    Y.AA.PREV.PROP.REC   =    AA$PREV.PROP.REC
    Y.AA.PROPERTY.CLASS.LIST   =    AA$PROPERTY.CLASS.LIST
    Y.AA.RENEWAL.ACTIVITY   =    AA$RENEWAL.ACTIVITY
    Y.AA.PROPERTY.NEW   =    AA$PROPERTY.NEW
    Y.AA.PROPERTY.OLD   =    AA$PROPERTY.OLD
    Y.AA.MASTER.ACTIVITY   =    AA$MASTER.ACTIVITY
    Y.AA.ACCR.DETS   =    AA$ACCR.DETS

RETURN
*-----------------------------------------------------
UPDATE.RESTORE:
*-----------------------------------------------------

    AA$PROPERTY.CLASS.ID   =   Y.AA.PROPERTY.CLASS.ID
    AA$PROPERTY.CLASS.REC   =    Y.AA.PROPERTY.CLASS.REC
    AA$PRODUCT.ARR   =    Y.AA.PRODUCT.ARR
    AA$RULE.TYPE   =    Y.AA.RULE.TYPE
    AA$MAND   =    Y.AA.MAND
    AA$FIELD.ACTIVITY   =    Y.AA.FIELD.ACTIVITY
    AA$FIELD.DATA.TYPE   =    Y.AA.FIELD.DATA.TYPE
    AA$DATED.ID   =    Y.AA.DATED.ID
    AA$CCY.ID   =    Y.AA.CCY.ID
    AA$OPT.CCY.ID   =    Y.AA.OPT.CCY.ID
    AA$MULTI.PROPERTY   =    Y.AA.MULTI.PROPERTY
    AA$CUST.ID   =    Y.AA.CUST.ID
    AA$ARR.ID   =    Y.AA.ARR.ID
    AA$R.ARRANGEMENT   =    Y.AA.R.ARRANGEMENT
    AA$PROP.EFF.DATE   =    Y.AA.PROP.EFF.DATE
    AA$PROPERTY.ID   =    Y.AA.PROPERTY.ID
    AA$PREV.PROD.PROP.REC   =    Y.AA.PREV.PROD.PROP.REC
    AA$OVERRIDE.LIST   =    Y.AA.OVERRIDE.LIST
    AA$ARR.LINK.TYPE   =    Y.AA.ARR.LINK.TYPE
    AA$ARR.PRODUCT.ID   =    Y.AA.ARR.PRODUCT.ID
    AA$ARR.CURRENCY   =    Y.AA.ARR.CURRENCY
    AA$ARR.CHANGED.FIELDS   =    Y.AA.ARR.CHANGED.FIELDS
    AA$RESERVED7   =    Y.AA.RESERVED7
    AA$PRODUCT.RECORD   =    Y.AA.PRODUCT.RECORD
    AA$PROD.PROP.RECORD   =    Y.AA.PROD.PROP.RECORD
    AA$ARR.PC.ID   =    Y.AA.ARR.PC.ID
    AA$ACTIVITY.ID   =    Y.AA.ACTIVITY.ID
    AA$ACTIVITY.EFF.DATE   =    Y.AA.ACTIVITY.EFF.DATE
    AA$ARRANGEMENT.STATUS   =    Y.AA.ARRANGEMENT.STATUS
    AA$TXN.REFERENCE   =    Y.AA.TXN.REFERENCE
    AA$CURR.ACTION   =    Y.AA.CURR.ACTION
    AA$R.ARRANGEMENT.ACTIVITY   =    Y.AA.R.ARRANGEMENT.ACTIVITY
    AA$XREF.ID.REQD   =    Y.AA.XREF.ID.REQD
    AA$LOCAL.REF.LIST   =    Y.AA.LOCAL.REF.LIST
    AA$ASSOC   =    Y.AA.ASSOC
    AA$F   =    Y.AA.F
    AA$FNO   =    Y.AA.FNO
    AA$N   =    Y.AA.N
    AA$T   =    Y.AA.T
    AA$CHECKFILE   =    Y.AA.CHECKFILE
    AA$RULE.TYPE   =    Y.AA.RULE.TYPE
*AA$ACTIVITY=Y.AA.ACTIVITY
    AA$CURR.ACTIVITY   =    Y.AA.CURR.ACTIVITY
    AA$LINKED.ACCOUNT   =    Y.AA.LINKED.ACCOUNT
    AA$NEW.ARRANGEMENT   =    Y.AA.NEW.ARRANGEMENT
    AA$PREV.PROP.REC   =    Y.AA.PREV.PROP.REC
    AA$PROPERTY.CLASS.LIST   =    Y.AA.PROPERTY.CLASS.LIST
    AA$RENEWAL.ACTIVITY   =    Y.AA.RENEWAL.ACTIVITY
    AA$PROPERTY.NEW   =    Y.AA.PROPERTY.NEW
    AA$PROPERTY.OLD   =    Y.AA.PROPERTY.OLD
    AA$MASTER.ACTIVITY   =    Y.AA.MASTER.ACTIVITY
    AA$ACCR.DETS   =    Y.AA.ACCR.DETS

END
