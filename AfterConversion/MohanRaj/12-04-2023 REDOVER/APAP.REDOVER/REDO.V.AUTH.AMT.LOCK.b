* @ValidationCode : MjotMTQ4MDA4MzY5OTpDcDEyNTI6MTY4MTMwMjMwMTQxMjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:55:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.AUTH.AMT.LOCK
*---------------------------------------------------------------------------------
*This is an input routine for the version APAP.H.GARNISH.DETAILS,INP, it will check
*whether the registration of garnishment for APAP customer or not
*----------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : BHARATH C
* Program Name  : REDO.V.INP.GARNISHMENT.MAINT
* ODR NUMBER    : ODR-2009-10-0531
* HD Reference  : HD1016159
*LINKED WITH:APAP.H.GARNISH.DETAILS AS version routine
*----------------------------------------------------------------------
*Input param = none
*output param =none
*-----------------------------------------------------------------------
*MODIFICATION DETAILS:
*4.1.2010       ODR-2009-10-0531
* 16-02-2011        Prabhu.N         B.88-HD1040884      Auto Launch of Enquiry
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_GTS.COMMON
    $INSERT I_F.VERSION
    $INSERT I_F.APAP.H.GARNISH.DETAILS
    $INSERT I_F.LOCKING

    GOSUB PROCESS
RETURN

PROCESS:
    CUS.ID = R.NEW(APAP.GAR.CUSTOMER)
*B.88-HD1040884---START OF CODE FOR AUTO LAUNCH*----
    TASK.NAME  = "ENQ REDO.E.MAINT.GARNISHMENT CUSTOMER EQ ":CUS.ID
    Y.CURRENT.GAR.REF=ID.NEW
    CALL System.setVariable("CURRENT.TXN.ID",Y.CURRENT.GAR.REF)
    CALL EB.SET.NEW.TASK(TASK.NAME)
*----END-----------------------------------------------

RETURN
*--------------
END
