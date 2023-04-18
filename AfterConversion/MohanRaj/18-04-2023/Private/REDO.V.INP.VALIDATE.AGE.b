* @ValidationCode : MjoxMDkwMjYzMDE0OkNwMTI1MjoxNjgxNzk3NDAwNjczOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 11:26:40
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
SUBROUTINE REDO.V.INP.VALIDATE.AGE
*----------------------------------------------------------------------------------
* Description: This subrouting is to be used at the input stage and at the VERSION
* CONTROL level which would apply for all the versions, and as well as for the
* application level itself. The purpose of this subroutine is to validate the age
* of the customer and check whether the customer's age is more than 150 years. If
* yes, then it would display an error
* Programmer : M.MURALI(Temenos Application Management)
* Creation Date: 01 Jul 09
*----------------------------------------------------------------------------------
* Modification History:
* DATE ODR WHO DESCRIPTION
* 14.12.2010 ODR2010120495 Janani. added override when relation code is modified
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER

    IF APPLICATION NE 'CUSTOMER' THEN
        RETURN
    END

    Y.LR.POS = 0
    CALL GET.LOC.REF('CUSTOMER', 'L.CU.AGE', Y.LR.POS)
* Single GET.LOC.REF need not be changed - Updated by TUS-Convert

    IF R.NEW(EB.CUS.DATE.OF.BIRTH) NE '' THEN

        Y.YEAR.DIFF = TODAY[1,4] - R.NEW(EB.CUS.DATE.OF.BIRTH)[1,4]
        Y.MONTH.DIFF = TODAY[5,2] - R.NEW(EB.CUS.DATE.OF.BIRTH)[5,2]
        Y.DATE.DIFF = TODAY[7,2] - R.NEW(EB.CUS.DATE.OF.BIRTH)[7,2]

        IF Y.MONTH.DIFF LT 0 THEN
            Y.YEAR.DIFF -= 1
        END ELSE
            IF (Y.MONTH.DIFF EQ 0 AND Y.DATE.DIFF LT 0) THEN
                Y.YEAR.DIFF -= 1
            END
        END

        IF Y.YEAR.DIFF GE 150 THEN

            ETEXT = 'EB-CUS.DOB.ERR'
            AF = EB.CUS.DATE.OF.BIRTH
            END.ERROR = 'Y'
            CALL STORE.END.ERROR

        END ELSE

            R.NEW(EB.CUS.LOCAL.REF)<1, Y.LR.POS> = Y.YEAR.DIFF

        END

    END ELSE

        R.NEW(EB.CUS.LOCAL.REF)<1, Y.LR.POS> = ''

    END

*/N.106 -S
    Y.CT.OLD.RELATION = DCOUNT(R.OLD(EB.CUS.RELATION.CODE),@VM)
    Y.CT.REL = 1
    LOOP
    WHILE Y.CT.REL LE Y.CT.OLD.RELATION
        IF R.OLD(EB.CUS.RELATION.CODE)<1,Y.CT.REL> EQ '13' THEN
            IF R.OLD(EB.CUS.RELATION.CODE)<1,Y.CT.REL> NE R.NEW(EB.CUS.RELATION.CODE)<1,Y.CT.REL> THEN
                TEXT = 'REDO.CU.MOD.TUTOR'
                CALL STORE.OVERRIDE('')

            END
            GOSUB REL.CUSTOMER
        END
        Y.CT.REL += 1
    REPEAT

RETURN
*-------------------------------------------------------------------------------------
REL.CUSTOMER:
**************
    IF R.OLD(EB.CUS.REL.CUSTOMER)<1,Y.CT.REL> NE R.NEW(EB.CUS.REL.CUSTOMER)<1,Y.CT.REL> THEN
        TEXT = 'REDO.CU.MOD.TUTOR'
        CALL STORE.OVERRIDE('')
    END
*/N.106 -E

RETURN
*----------------------------------------------------------------------------------
END
