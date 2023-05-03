* @ValidationCode : MjotNjA1MTQwNDgxOkNwMTI1MjoxNjgxODkwNTUwNTA2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:19:10
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
SUBROUTINE REDO.V.VAL.FHA.VALIDATE
*------------------------------------------------------------------------------------------------------------------
* Developer    : RAMKUMAR.G
* Date         : 04.09.2010
* Description  : REDO.V.VAL.FHA.VALIDATE
*------------------------------------------------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : --N/A--
* Out : --N/A--
*------------------------------------------------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : --N/A--
* Called By : --N/A--
*------------------------------------------------------------------------------------------------------------------
* Revision History:
* -----------------
* Version          Date          Name              Description
* -------          ----          ----              ------------
*   1.0         04.09.2010     Ramkumar G    Attahced as a validation routine in the versions
*                                            APAP.H.INSURANCE.DETAILS,INP and APAP.H.INSURANCE.DETAILS,MODIFICATION
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,++ TO +=1
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.APAP.H.INSURANCE.DETAILS


    GOSUB INITIALISATION
    GOSUB PROCESS
RETURN
*

*---------------
INITIALISATION:
*---------------
    Y.CASE.NO = R.NEW(INS.DET.FHA.CASE.NUMBER)
    Y.FHA.COUNT = 0
*
    FN.APAP.H.INSURANCE.DETAILS = 'F.APAP.H.INSURANCE.DETAILS'
    F.APAP.H.INSURANCE.DETAILS = ''
    CALL OPF(FN.APAP.H.INSURANCE.DETAILS,F.APAP.H.INSURANCE.DETAILS)
*
RETURN


*--------
PROCESS:
*--------
    VAR.COUNT = 1
    Y.INS.POLICY.TYPE = R.NEW(INS.DET.INS.POLICY.TYPE)
    Y.INS.COUNT = DCOUNT(Y.INS.POLICY.TYPE,@VM)
    Y.FHA.NO = R.NEW(INS.DET.FHA.CASE.NUMBER)
    Y.FHA.CNT = DCOUNT(Y.FHA.NO,@VM)
    IF Y.FHA.CNT NE 0 THEN
        IF Y.FHA.CNT NE Y.INS.COUNT THEN
            AF = INS.DET.FHA.CASE.NUMBER
            AV = VAR.COUNT
            ETEXT = "EB-FHA.VALUE.NULL"
            CALL STORE.END.ERROR
        END
    END
    LOOP
    WHILE VAR.COUNT LE Y.INS.COUNT
        Y.CLASS.POLICY1 = R.NEW(INS.DET.CLASS.POLICY)<1,VAR.COUNT>
        Y.INS.POLICY.TYPE1 = R.NEW(INS.DET.INS.POLICY.TYPE)<1,VAR.COUNT>
        Y.FHA.CASE.NUMBER = R.NEW(INS.DET.FHA.CASE.NUMBER)<1,VAR.COUNT>
        IF Y.CLASS.POLICY1 EQ "FHA" AND Y.INS.POLICY.TYPE1 NE "FHA" THEN
            IF Y.FHA.CASE.NUMBER NE '' THEN
                AF = INS.DET.FHA.CASE.NUMBER
                AV = VAR.COUNT
                ETEXT = "EB-FHA.VALUE.NULL"
                CALL STORE.END.ERROR
            END
        END
        IF Y.CLASS.POLICY1 NE "FHA" AND Y.INS.POLICY.TYPE1 EQ "FHA" THEN
            IF Y.FHA.CASE.NUMBER NE '' THEN
                AF = INS.DET.FHA.CASE.NUMBER
                AV = VAR.COUNT
                ETEXT = "EB-FHA.VALUE.NULL"
                CALL STORE.END.ERROR
            END
        END
        IF Y.FHA.CASE.NUMBER NE '' THEN
            IF Y.CLASS.POLICY1 NE "FHA" OR Y.INS.POLICY.TYPE1 NE "FHA" THEN
                AF = INS.DET.FHA.CASE.NUMBER
                AV = VAR.COUNT
                ETEXT = "EB-FHA.VALUE.NULL"
                CALL STORE.END.ERROR
            END
        END
        VAR.COUNT += 1
    REPEAT

RETURN
END
