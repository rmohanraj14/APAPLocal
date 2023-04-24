* @ValidationCode : Mjo2NTc5MDcwMjg6Q3AxMjUyOjE2ODEyMTQ3MTQ1ODM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:35:14
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
SUBROUTINE REDO.INP.STOP.PAY.STATUS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This subroutine would serve as a cross validation level validation routine
* The purpose of this routine is to check the field STOPPAYMENT.STATUS if the
* value is specified as a CONFIRMED and authorised the value cannot be changed
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------------------------------------------------------------------------------
*   Date               who           Reference            Description
* 25-Nov-2009       SHANKAR RAJU                            Initial Creation
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.REDO.PAYMENT.STOP.ACCOUNT

*------------------------------MAIN-------------------------------------
    GOSUB INIT
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------

    FN.REDO.PAYMENT.STOP.ACCOUNT = 'F.REDO.PAYMENT.STOP.ACCOUNT'
    F.REDO.PAYMENT.STOP.ACCOUNT = ''
    VALUE.NEW = ''
    CALL OPF(FN.REDO.PAYMENT.STOP.ACCOUNT,F.REDO.PAYMENT.STOP.ACCOUNT)

RETURN
*-----------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------

    STATUS.NOS = DCOUNT(R.NEW(REDO.PS.ACCT.PAY.STOP.STATUS),@VM)

    START.COUNT = 1

    LOOP
    WHILE START.COUNT LE STATUS.NOS
        Y.VALUE = R.OLD(REDO.PS.ACCT.PAY.STOP.STATUS)<1,START.COUNT>
        IF Y.VALUE EQ 'CONFIRMED' THEN

            VALUE.NEW = R.NEW(REDO.PS.ACCT.PAY.STOP.STATUS)<1,START.COUNT>

            IF VALUE.NEW EQ 'NONCONFIRMED' THEN

                T(REDO.PS.ACCT.CHEQUE.FIRST)<3> = "NOCHANGE"

                T(REDO.PS.ACCT.CHEQUE.LAST)<3> = "NOCHANGE"

                ETEXT = 'EB-STATUS'
                AF=REDO.PS.ACCT.PAY.STOP.STATUS
* AV=REDO.PS.ACCT.PAY.STOP.STATUS
                AS = START.COUNT
                CALL STORE.END.ERROR

            END
        END

        START.COUNT += 1 ;*R22 Auto Code conversion

    REPEAT

RETURN
*-----------------------------------------------------------------------

END
*-----------------------------------------------------------------------
