* @ValidationCode : Mjo4NjUxNzEwMzM6Q3AxMjUyOjE2ODEzODI2NjAxMzQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:14:20
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
SUBROUTINE REDO.V.BAUT.UPD.CUS.DOB
*--------------------------------------------------------------------------------------------
* Description: This subroutine is used for updating the customer id for the respective date
* of birth of the customer. This subroutine would be triggered at the before authorisation
* stage and would be triggered at the VERSION.CONTROL level
* The file it updates is, FBNK.CUSTOMER.DOB, which is a database level file
*--------------------------------------------------------------------------------------------
* Programmer: M.MURALI (Temenos Application Management)
* Creation Date: 01 Jul 09
*--------------------------------------------------------------------------------------------
* Modification History:
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion      FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER

    GOSUB INIT
    GOSUB PROCESS

RETURN

*--------------------------------------------------------------------------------------------
* Initialisation paragraph for the variables and opening the files
INIT:
*----

    FN.CUSTOMER.DOB = 'F.CUSTOMER.DOB'
    F.CUSTOMER.DOB = ''
    CALL OPF(FN.CUSTOMER.DOB, F.CUSTOMER.DOB)

RETURN

*--------------------------------------------------------------------------------------------
* Main process paragraph where the processing begins
PROCESS:
*-------


    Y.DATE.OF.BIRTH.NEW = R.NEW(EB.CUS.DATE.OF.BIRTH)[5,4]
    Y.DATE.OF.BIRTH.OLD = R.OLD(EB.CUS.DATE.OF.BIRTH)[5,4]

    IF (Y.DATE.OF.BIRTH.NEW EQ Y.DATE.OF.BIRTH.OLD) THEN
        RETURN
    END

    R.CUSTOMER.DOB.NEW = ''
    Y.READ.ERR = ''
    Y.OPTIONS = ''
    CALL F.READU(FN.CUSTOMER.DOB, Y.DATE.OF.BIRTH.NEW, R.CUSTOMER.DOB.NEW, F.CUSTOMER.DOB, Y.READ.ERR, Y.OPTIONS)

* Update for CUSTOMER migration performance optimization
    IF Y.DATE.OF.BIRTH.OLD NE "" THEN
        R.CUSTOMER.DOB.OLD = ''
        Y.READ.ERR = ''
        Y.OPTIONS = ''
        CALL F.READU(FN.CUSTOMER.DOB, Y.DATE.OF.BIRTH.OLD, R.CUSTOMER.DOB.OLD, F.CUSTOMER.DOB, Y.READ.ERR, Y.OPTIONS)
    END

    BEGIN CASE

        CASE (Y.DATE.OF.BIRTH.NEW EQ '') AND (Y.DATE.OF.BIRTH.OLD NE '')

            GOSUB LOCATE.AND.UPDATE.OLD.RECORD

        CASE (Y.DATE.OF.BIRTH.OLD EQ '') AND (Y.DATE.OF.BIRTH.NEW NE '')

            GOSUB UPDATE.NEW.RECORD

        CASE (Y.DATE.OF.BIRTH.NEW NE Y.DATE.OF.BIRTH.OLD) AND (Y.DATE.OF.BIRTH.OLD NE '')

            GOSUB LOCATE.AND.UPDATE.OLD.RECORD
            GOSUB UPDATE.NEW.RECORD

    END CASE

    CALL F.RELEASE(FN.CUSTOMER.DOB, Y.DATE.OF.BIRTH.OLD, F.CUSTOMER.DOB)
    CALL F.RELEASE(FN.CUSTOMER.DOB, Y.DATE.OF.BIRTH.NEW, F.CUSTOMER.DOB)

RETURN
*--------------------------------------------------------------------------------------------
* This paragraph updates the old any existing record in the system
LOCATE.AND.UPDATE.OLD.RECORD:
*----------------------------

    Y.POS = 0
    LOCATE ID.NEW IN R.CUSTOMER.DOB.OLD<1> SETTING Y.POS THEN
        DEL R.CUSTOMER.DOB.OLD<Y.POS>
        CALL F.WRITE(FN.CUSTOMER.DOB, Y.DATE.OF.BIRTH.OLD, R.CUSTOMER.DOB.OLD)
    END

RETURN
*--------------------------------------------------------------------------------------------
* This paragraph updates the new record R.NEW with the proper values of the customer ID
UPDATE.NEW.RECORD:
*-----------------
    LOCATE ID.NEW IN R.CUSTOMER.DOB.NEW SETTING DOB.POS ELSE
        IF R.CUSTOMER.DOB.NEW NE '' THEN
            R.CUSTOMER.DOB.NEW := @FM : ID.NEW
        END ELSE
            R.CUSTOMER.DOB.NEW = ID.NEW
        END

        CALL F.WRITE(FN.CUSTOMER.DOB, Y.DATE.OF.BIRTH.NEW, R.CUSTOMER.DOB.NEW)
    END

RETURN
*--------------------------------------------------------------------------------------------
END
*--------------------------------------------------------------------------------------------
