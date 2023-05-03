$PACKAGE APAP.REDOCHNLS
* @ValidationCode : MjoxNTE0Nzk5MDQyOkNwMTI1MjoxNjgwNzc0MjQ2NzM2OkhhcmlzaHZpa3JhbUM6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:14:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

SUBROUTINE AI.REDO.GET.PLEDGED.AMT
*-----------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : Martin Macias
* Program Name :
*-----------------------------------------------------------------------------
* Description    :  This routine will get pledged amount for a Customer Acct if any
* Linked with    :
* In Parameter   :
* Out Parameter  :
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                DESCRIPTION
* 04-APR-2023     Conversion tool    R22 Auto conversion       I to I.VAR
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_System

    $INSERT I_F.APAP.H.GARNISH.DETAILS

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*----------*
INITIALISE:
*----------*

    FN.APAP.H.GARNISH.DETAILS = "F.APAP.H.GARNISH.DETAILS"
    F.APAP.H.GARNISH.DETAILS = ''

    ACCT.NO = O.DATA
    PLEDGED.AMT = 0

RETURN

*----------*
OPEN.FILES:
*----------*

    CALL OPF(FN.APAP.H.GARNISH.DETAILS,F.APAP.H.GARNISH.DETAILS)

RETURN

*--------*
PROCESS:
*--------*

    SEL.CMD = "SELECT ":FN.APAP.H.GARNISH.DETAILS:" WITH ACCOUNT.NO EQ ":ACCT.NO
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,Y.ERR)

    FOR I.VAR = 1 TO NO.OF.REC
        CALL F.READ(FN.APAP.H.GARNISH.DETAILS,SEL.LIST<I.VAR>,R.PLEDGED,F.APAP.H.GARNISH.DETAILS,PLEDGED.ERR)
        ACCT.LIST = R.PLEDGED<APAP.GAR.ACCOUNT.NO>
        LOCATE ACCT.NO IN ACCT.LIST<1,1> SETTING Y.ACCT.POS THEN
            PLEDGED.AMT += R.PLEDGED<APAP.GAR.GARNISH.AMT,Y.ACCT.POS>
        END
    NEXT I.VAR

    O.DATA = PLEDGED.AMT

RETURN

END
