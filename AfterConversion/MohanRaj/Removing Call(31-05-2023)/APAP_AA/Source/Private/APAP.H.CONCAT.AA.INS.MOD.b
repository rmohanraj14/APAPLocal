$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE APAP.H.CONCAT.AA.INS.MOD
* ====================================================================================
*
* Subroutine Type : Authroutine
* Attached to     : APAP.H.INSURANCE.DETAILS,REDO.AUTORIZACION
* Attached as     : Auth Rouine
* Primary Purpose : Update Concat File
*
*
* Incoming:
* ---------
* NA
*
* Outgoing:
* ---------
* NA
*
*-----------------------------------------------------------------------------------
*Modification History:
*
* Date                     Who                        Reference                                        Description
* ----                    ----                                ----                                        ----
* 29-March-2023          Ajith Kumar              Manual R22 Code Conversion                Package Name added APAP.AA
* 29-March-2023       Conversion Tool                            R22 Auto Code Conversion                              VM to @VM
*


* Development for : Asociacion Popular APAP
* Development by  : Jorge Valarezo
* Date            : 02 APR 2013
*=======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.APAP.H.INSURANCE.DETAILS
    $INSERT I_F.APAP.AA.INSURANCE
*
*************************************************************************
*


    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN


*
* =========
INITIALISE:
* =========
*
    FN.APAP.INSURANCE.AA = 'F.APAP.AA.INSURANCE'
    F.APAP.INSURANCE.AA = ''

    FN.INS.DET      =  'F.APAP.H.INSURANCE.DETAILS'
    F.INS.DET       =  ''

RETURN
*
* =========
OPEN.FILES:
* =========
*
    CALL OPF(FN.APAP.INSURANCE.AA,F.APAP.INSURANCE.AA)
    CALL OPF(FN.INS.DET,F.INS.DET)
RETURN

* ======
PROCESS:
* ======
*ADD ALL VALUE WHICH ARE IN R.NEW BUT NOT IN R.OLD
    ACTION.TO.DO = 'I'
    BASE.ARRAY = R.NEW(INS.DET.ASSOCIATED.LOAN)
    FIND.ARRAY = R.OLD(INS.DET.ASSOCIATED.LOAN)
    GOSUB COMPARE.ARRAYS
    GOSUB UPDATE.CONACT
*DELETE ALL VALUES WHICH ARE IN R.OLD BUT NOT IN R.NEW
    ACTION.TO.DO = 'D'
    BASE.ARRAY = R.OLD(INS.DET.ASSOCIATED.LOAN)
    FIND.ARRAY = R.NEW(INS.DET.ASSOCIATED.LOAN)
    GOSUB COMPARE.ARRAYS
    GOSUB UPDATE.CONACT


RETURN


*===================
UPDATE.CONACT:
*===================
    IF NOT(LIST.LOAN) THEN
        RETURN
    END
    NO.OF.LOANS = DCOUNT(LIST.LOAN,@VM)
    FOR POSSITION = 1 TO NO.OF.LOANS
        LOAN.ID = LIST.LOAN<1,POSSITION>
        CALL CONCAT.FILE.UPDATE(FN.APAP.INSURANCE.AA,LOAN.ID,ID.NEW,ACTION.TO.DO,'AR')
    NEXT POSSITION
RETURN

*=============
COMPARE.ARRAYS:
*==============
    NO.ITMS = DCOUNT(BASE.ARRAY,@VM)
    LIST.LOAN = ''
    ITR = 1
    LOOP
    WHILE ITR LE NO.ITMS
        LOCATE BASE.ARRAY<1,ITR> IN FIND.ARRAY<1,1> SETTING Y.POS ELSE
            LIST.LOAN <1,-1> = BASE.ARRAY<1,ITR>
        END
        NO.ITMS -= 1
    REPEAT
RETURN
END
