* @ValidationCode : Mjo2NzM0ODgwNjM6Q3AxMjUyOjE2ODAxODQ2NzMzODM6SVRTUzotMTotMToyNTk6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 259
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.FC.CL.DISBURSTMENT.AA
*
* ====================================================================================
*
*    - Gets the information related to the AA specified in input parameter
*
*    - REGISTER DISBURSTMENT FOR REDO.CREATE.ARRANGEMENT TO CREDIT FACTORY
*
* ====================================================================================
*
* Subroutine Type :
* Attached to     :
* Attached as     :
* Primary Purpose :
*
*
* Incoming:
* ---------
*
*
*
* Outgoing:

* ---------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for :APAP
* Development by  :btorresalbornoz@temenos.com
* Date            :June 2011
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION               ADDITION LOGIC CHANGED
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*


*=======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.FC.CL.BALANCE
    $INSERT I_REDO.FC.COMMON
    $INSERT I_F.REDO.CREATE.ARRANGEMENT

*
*************************************************************************
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

*
RETURN
*
* ======
PROCESS:
* ======

    CALL F.READ(FN.REDO.FC.CL.BALANCE,DES.AA.ID,R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,ERR.MSJ)
    IF R.REDO.FC.CL.BALANCE THEN
        DES.AMOUNT.OG = R.REDO.FC.CL.BALANCE<FC.CL.AA.AMOUNT>
        DES.AMOUNT.BALANCE= R.REDO.FC.CL.BALANCE<FC.CL.AA.BALANCE>
        DES.AMOUNT.BALANCE += DES.AMOUNT ; *AUTO R22 CODE CONVERSION

        IF DES.AMOUNT.BALANCE LE DES.AMOUNT.OG THEN ; *AUTO R22 CODE CONVERSION <= to LE
            R.REDO.FC.CL.BALANCE<FC.CL.AA.BALANCE>    = DES.AMOUNT.BALANCE
            CALL F.WRITE(FN.REDO.FC.CL.BALANCE,DES.AA.ID,R.REDO.FC.CL.BALANCE)

        END ELSE
            AF = REDO.FC.AVAIL.COLL.BAL.BR
            ETEXT = "EB-FC-NOT-PAY-MORE"
            CALL STORE.END.ERROR


        END
    END

RETURN
*
* =========
OPEN.FILES:
* =========
*
    CALL OPF(FN.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE)

RETURN
*
* =========
INITIALISE:
* =========
*
    LOOP.CNT        = 1
    MAX.LOOPS       = 1
    PROCESS.GOAHEAD = 1



    FN.REDO.FC.CL.BALANCE="F.REDO.FC.CL.BALANCE"
    F.REDO.FC.CL.BALANCE=""

* Y.DIS.AMOUNT=R.NEW(FT.DEBIT.AMOUNT)
* DES.AA.ID=R.NEW(FT.IN.DEBIT.ACCT.NO)

RETURN

* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1

        END CASE

        LOOP.CNT +=1
    REPEAT
*
RETURN
*

END
