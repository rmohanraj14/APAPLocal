* @ValidationCode : MjotNjc1MjYxOTIyOkNwMTI1MjoxNjgwNzcyOTM1NjUzOkhhcmlzaHZpa3JhbUM6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2023 14:52:15
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
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.ESTATUSCTA(R.DATA)
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is an Nofile routine to be used in enquiry REDO.IVR.ESTATUSCTA
* related to C.3 IVR Interface.
*
* Input/Output:
*--------------
* IN : ACCOUNT.NO
* OUT : R.DATA (ALL DATA)
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who                   Reference               Description
* 17-FEB-2011    RMONDRAGON            ODR-2011-02-0099          FIRST VERSION
* 26-ABR-2012    RMONDRAGON            ODR-2011-02-0099          PACS00192549
* 04-APR-2023     Conversion tool   R22 Auto conversion         VM to @VM
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
* </region>
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*
*****
INIT:
*****

    Y.APPL = "ACCOUNT"
    Y.FLD = "L.AC.STATUS1":@VM:"L.AC.STATUS2":@VM:"L.AC.NOTIFY.1"
    Y.POS = ""
    CALL MULTI.GET.LOC.REF(Y.APPL,Y.FLD,Y.POS)
    Y.AC.STATUS1.POS = Y.POS<1,1>
    Y.AC.STATUS2.POS = Y.POS<1,2>
    Y.AC.NOTIFY1.POS = Y.POS<1,3>

RETURN

*********
OPENFILES:
*********
*Open file ACCOUNT

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN

********
PROCESS:
********

    LOCATE "ACCOUNT.NO" IN D.FIELDS<1> SETTING ACCOUNT.NO.POS THEN
        Y.ACCOUNT.NO = D.RANGE.AND.VALUE<ACCOUNT.NO.POS>
        COMI = Y.ACCOUNT.NO
        CALL IN2POSANT(19,'')
        Y.ACCOUNT.NO = COMI
    END

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.NO,Y.ACCOUNT.REC,F.ACCOUNT,ACCOUNT.ERR)
    IF Y.ACCOUNT.REC THEN
        Y.AC.POS.RES = Y.ACCOUNT.REC<AC.POSTING.RESTRICT>
        Y.AC.STATUS1 = Y.ACCOUNT.REC<AC.LOCAL.REF><1,Y.AC.STATUS1.POS>
        Y.AC.STATUS2 = Y.ACCOUNT.REC<AC.LOCAL.REF><1,Y.AC.STATUS2.POS>
        Y.AC.NOTIFY1 = Y.ACCOUNT.REC<AC.LOCAL.REF><1,Y.AC.NOTIFY1.POS>

        IF Y.AC.POS.RES EQ "1" OR Y.AC.POS.RES EQ "3" THEN
            R.DATA<-1> = "F"
            RETURN
        END

        IF Y.AC.STATUS1 EQ "6MINACTIVE" OR Y.AC.STATUS1 EQ "3YINACTIVE" OR Y.AC.STATUS1 EQ "ABANDONED" THEN
            R.DATA<-1> = "F"
            RETURN
        END

        IF Y.AC.STATUS2 EQ "DECEASED" THEN
            R.DATA<-1> = "F"
            RETURN
        END

        IF Y.AC.NOTIFY1 EQ "NOTIFY.OFFICER" OR Y.AC.NOTIFY1 EQ "NOTIFY.MGMT.MONEY.LAUNDRY.PREV" THEN
            R.DATA<-1> = "F"
            RETURN
        END

        R.DATA<-1> = "T"
    END ELSE
        R.DATA<-1> = "F"
    END

RETURN

END
