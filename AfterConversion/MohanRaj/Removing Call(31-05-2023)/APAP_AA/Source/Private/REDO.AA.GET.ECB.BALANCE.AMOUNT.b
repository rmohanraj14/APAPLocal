* @ValidationCode : MjotMjA4MTQ3NTQzNzpDcDEyNTI6MTY4MzY5ODQyMTczNjpJVFNTOi0xOi0xOi0zODoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -38
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.GET.ECB.BALANCE.AMOUNT(ACCOUNT.ID, BALANCE.TYPE, REQUEST.DATE, BALANCE.AMOUNT,RET.ERROR)

*** <region name= Synopsis of the Routine>
***
** This routine accepts an Account ID, Balance Type and Request Date
** Gets the Balance amount for all virtual balance types if the BAL.TYPE is 'VIRTUAL'
** and returns the total balance amount for given Balance Type.
** Arguments:
** IN  - ACCOUNT.ID
**       BALANCE.TYPE
**       REQUEST.DATE
**
** OUT - BALANCE.AMOUNT
**       RET.ERROR
***</region>
*---------------------------------------------------------------------------

*** <region name= Modification History>
*** Date               who                   Reference              
* 29-03-2023          CONVERSTION TOOL     R22 AUTO CONVERSTION VM TO @VM AND F.REAR TO CACHE.READ
* 29-03-2023          ANIL KUMAR B         R22 MANUAL CONVERSTION -NO CHANGES
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
***
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AC.BALANCE.TYPE
    COM/AA.REDO.BAL.TYPES/AA.REDO.BAL.ID,AA.REDO.BAL.REC

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main Process>
***
    GOSUB INITIALISE
    IF ACCOUNT.ID AND BALANCE.TYPE THEN
        GOSUB GET.BALANCE
    END ELSE
        RET.ERROR = "ACCOUNT.ID AND BALANCE.TYPE ARE MANDATORY"
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise variables>
***
INITIALISE:

    BAL.AMOUNT = ''
    REQUEST.TYPE = ''
    REQUEST.TYPE<4> = "ECB"   ;* Always take balance from ECB file
    BALANCE.AMOUNT = ''
    FINAL.BAL.AMOUNT = ''
    FN.BALANCE.TYPE = 'F.AC.BALANCE.TYPE'
    F.BALANCE.TYPE = ''


    IF NOT(REQUEST.DATE) THEN
        REQUEST.DATE = TODAY
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get all virtual balance types if the BAL.TYPE is 'VIRTAUL'>
*** <desc></desc>
GET.BALANCE:


    R.BALANCE.TYPE = ''
    BAL.ERR = ''
    LOCATE BALANCE.TYPE IN AA.REDO.BAL.ID<1> SETTING BAL.POS THEN
        TEMP.R.BALANCE.TYPE = AA.REDO.BAL.REC<BAL.POS>
        TEMP.R.BALANCE.TYPE = RAISE(TEMP.R.BALANCE.TYPE)
        R.BALANCE.TYPE = TEMP.R.BALANCE.TYPE
    END ELSE
        CALL CACHE.READ(FN.BALANCE.TYPE, BALANCE.TYPE, R.BALANCE.TYPE, BAL.ERR) ;*R22 AUTO CONVERSTION F.READ TO CACHE.READ
        AA.REDO.BAL.ID<-1> = BALANCE.TYPE
        TEMP.R.BALANCE.TYPE = R.BALANCE.TYPE
        TEMP.R.BALANCE.TYPE = LOWER(TEMP.R.BALANCE.TYPE)
        AA.REDO.BAL.REC<-1> = TEMP.R.BALANCE.TYPE
    END
    IF R.BALANCE.TYPE<AC.BT.REPORTING.TYPE> EQ "VIRTUAL" THEN         ;* find all virtual balance types and then get balance amount for each type

        ALL.BAL.TYPES = R.BALANCE.TYPE<AC.BT.VIRTUAL.BAL>
        TOT.BAL.TYPES = DCOUNT(ALL.BAL.TYPES,@VM)
        FOR BALANCE.CNT = 1 TO TOT.BAL.TYPES
            BAL.TYPE = ALL.BAL.TYPES<1,BALANCE.CNT>

            GOSUB GET.BAL.AMT
            FINAL.BAL.AMOUNT += BAL.AMOUNT

        NEXT BALANCE.CNT
        BALANCE.AMOUNT = FINAL.BAL.AMOUNT
    END ELSE
        BAL.TYPE = BALANCE.TYPE
        GOSUB GET.BAL.AMT
        BALANCE.AMOUNT = BAL.AMOUNT     ;* Return total balacne amount for the given Balance.Type
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get balance amount for the corresponding BALANCE type>
***

GET.BAL.AMT:

**Always get balance from ECB file.
    BALANCE.DETAILS = ''
    CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID,BAL.TYPE,REQUEST.TYPE,REQUEST.DATE,'','',BALANCE.DETAILS,"")
    BAL.AMOUNT = BALANCE.DETAILS<IC.ACT.BALANCE,1>

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
