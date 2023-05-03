* @ValidationCode : MjoxMjM4MTU5MDY4OkNwMTI1MjoxNjgxNzI2NDgyMTMzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 15:44:42
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
SUBROUTINE REDO.V.INP.CHK.BENFIC
*-----------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : TAM
* Program Name  : REDO.V.INP.CHK.BENFIC
* ODR NUMBER    : PACS0006290 - ODR-2011-01-0492
*--------------------------------------------------------------------------------------
* Description   : This routine attached with VERSION.CONTROL>AZ.ACCOUNT as a input routine to check some conditions
* In parameter  : none
* out parameter : none
*--------------------------------------------------------------------------------------
* Modification History :
*--------------------------------------------------------------------------------------
*   DATE             WHO             REFERENCE                      DESCRIPTION
* 01-06-2011      MARIMUTHU s     ODR-2011-01-0492 (PACS0006290)    Initial Creation
* 05-08-2011      MARIMUTHU S     PACS00099482
* 26-AUG-2011     JEEVA T         PACS00112728
* 14-SEP-2011     JEEVA T         PACS00112728
* 29-DEC-2011     JEEVA T         PACS00151769                      BaseLine
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM,SM TO @SM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.RELATION
    $INSERT I_F.CUSTOMER

MAIN:


    GOSUB PROCESS
    IF NOT(Y.FLAG.VAL) THEN
        GOSUB CHECKING.TUTOR
    END
    GOSUB PGM.END

PROCESS:


    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.RELATION = 'F.RELATION'
    F.RELATION = ''
    CALL OPF(FN.RELATION,F.RELATION)

    Y.FLAG.VAL = ''
    APPLNS = 'AZ.ACCOUNT':@FM:'ACCOUNT':@FM:'CUSTOMER'
    LOC.FIELDS = 'L.TYPE.INT.PAY':@VM:'BENEFIC.NAME':@VM:'BENEFIC.ACC.NO':@VM:'BENEFIC.BNK.CDE':@FM:'L.AC.PAYMT.MODE':@FM:'L.CU.TIPO.CL'
    LOC.POS = ''
    CALL MULTI.GET.LOC.REF(APPLNS,LOC.FIELDS,LOC.POS)
    POS.PAY.MDE = LOC.POS<1,1>
    POS.BENE.NAME =  LOC.POS<1,2>
    POS.BENE.AC.NO = LOC.POS<1,3>
    POS.BENE.BNK.CDE = LOC.POS<1,4>
    POS.AC.PAY.MDE = LOC.POS<2,1>
    POS.TIPO.CUS = LOC.POS<3,1>

    Y.AC.ID = ID.NEW
    CALL F.READ(FN.ACCOUNT,Y.AC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    Y.PAY.MODE = R.ACCOUNT<AC.LOCAL.REF,POS.AC.PAY.MDE>

    GOSUB CHECK.PAY.MODE

    Y.NAME = R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME>
    IF NOT(R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME>) ELSE
        Y.FLAG.VAL = 1
        RETURN
    END
    Y.CUSTOMER = R.ACCOUNT<AC.CUSTOMER>
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUS.ERR)


**PACS00099482 - S
    IF R.CUSTOMER<EB.CUS.LOCAL.REF,POS.TIPO.CUS> EQ 'PERSONA FISICA' OR R.CUSTOMER<EB.CUS.LOCAL.REF,POS.TIPO.CUS> EQ 'CLIENTE MENOR' THEN
        Y.GIVEN.NAME = R.CUSTOMER<EB.CUS.GIVEN.NAMES>
        Y.FAM.NAME = R.CUSTOMER<EB.CUS.FAMILY.NAME>
        CHANGE " " TO "*" IN Y.GIVEN.NAME
        Y.VAR1.CNT = DCOUNT(Y.GIVEN.NAME,"*")
        Y.GIVEN.NAME.1 = FIELD(Y.GIVEN.NAME,"*",1,Y.VAR1.CNT-1)
        CHANGE "*" TO " " IN Y.GIVEN.NAME.1

        CHANGE " " TO "*" IN Y.FAM.NAME
        Y.VAR2.CNT = DCOUNT(Y.FAM.NAME,"*")
        Y.FAM.NAME.1 = FIELD(Y.FAM.NAME,"*",1,Y.VAR2.CNT-1)
        CHANGE "*" TO " " IN Y.FAM.NAME.1

        Y.FAM.NAME.2 = FIELD(Y.FAM.NAME,"*",Y.VAR2.CNT,1)
        Y.JOINT.NAME = Y.GIVEN.NAME.1:" ":Y.FAM.NAME.1:" ":Y.FAM.NAME.2[1,1]
    END

    IF R.CUSTOMER<EB.CUS.LOCAL.REF,POS.TIPO.CUS> EQ 'PERSONA JURIDICA' THEN
        Y.NAME.1 = R.CUSTOMER<EB.CUS.NAME.1,1>
        IF Y.NAME.1 EQ '' THEN
            Y.NAME.1 = R.CUSTOMER<EB.CUS.NAME.1,2>
        END
        Y.NAME.2 = R.CUSTOMER<EB.CUS.NAME.2,1>
        IF Y.NAME.2 EQ '' THEN
            Y.NAME.2 = R.CUSTOMER<EB.CUS.NAME.2,2>
        END
        CHANGE " " TO "*" IN Y.NAME.1
        Y.VAR2.1.CNT = DCOUNT(Y.NAME.1,"*")
        Y.NAME.1.1 = FIELD(Y.NAME.1,"*",1,Y.VAR2.1.CNT-1)
        CHANGE "*" TO " " IN Y.NAME.1.1

        CHANGE " " TO "*" IN Y.NAME.2
        Y.VAR2.2.CNT = DCOUNT(Y.NAME.2,"*")
        Y.NAME.1.2 = FIELD(Y.NAME.2,"*",1,Y.VAR2.2.CNT-1)
        CHANGE "*" TO " " IN Y.NAME.1.2

        Y.NAME.1.3 = FIELD(Y.NAME.2,"*",Y.VAR2.2.CNT,1)
        Y.JOINT.NAME = Y.NAME.1.1:' ':Y.NAME.1.2:' ':Y.NAME.1.3[1,1]
    END

    Y.LEN.VAL1 = LEN(Y.JOINT.NAME)
    IF Y.LEN.VAL1 GT 65 THEN
        R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME,1> = Y.JOINT.NAME[1,65]
        R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME,2> = Y.JOINT.NAME[66,65]
    END ELSE
        R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME,1> = Y.JOINT.NAME
    END

RETURN
*----------------------------------
CHECK.PAY.MODE:
*----------------------------------
    IF Y.PAY.MODE EQ 'Transfer.via.ACH' THEN
        IF R.NEW(AZ.LOCAL.REF)<1,POS.BENE.AC.NO> EQ '' THEN
            AF = AZ.LOCAL.REF
            AV = POS.BENE.AC.NO
            ETEXT = 'EB-BENEFIC.AC.NO'
            CALL STORE.END.ERROR
        END
        IF R.NEW(AZ.LOCAL.REF)<1,POS.BENE.BNK.CDE> EQ '' THEN
            AF = AZ.LOCAL.REF
            AV = POS.BENE.BNK.CDE
            ETEXT = 'EB-BENEFIC.BNK.CODE'
            CALL STORE.END.ERROR
        END
    END
    IF Y.PAY.MODE EQ 'Transfer' THEN
        R.NEW(AZ.LOCAL.REF)<1,POS.PAY.MDE>='Credit.To.Account'
    END
    IF Y.PAY.MODE EQ 'Admin.check' THEN
        R.NEW(AZ.LOCAL.REF)<1,POS.PAY.MDE>='Admin.check'
    END
    IF Y.PAY.MODE EQ 'Transfer.via.ACH' THEN
        R.NEW(AZ.LOCAL.REF)<1,POS.PAY.MDE>='Transfer.via.ACH'
    END
RETURN
*------------------PACS00112728*----------------
CHECKING.TUTOR:
*------------------PACS00112728-----------------
    Y.ACCOUNT.ID = ID.NEW
    Y.LIST.NAME = ''
*CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR.ACC)
    Y.JOINT.HOLDER = R.ACCOUNT<AC.JOINT.HOLDER>
    Y.RELATION.CODE = R.ACCOUNT<AC.RELATION.CODE>
    Y.CNT = 1
    Y.COUNT = DCOUNT(Y.RELATION.CODE,@VM)
    LOOP
    WHILE Y.CNT LE Y.COUNT
        Y.CUS.ID.VAL = Y.JOINT.HOLDER<1,Y.CNT>
        Y.JOINT.ID = Y.RELATION.CODE<1,Y.CNT>
        CALL F.READ(FN.RELATION,Y.JOINT.ID,R.RELATION,F.RELATION,Y.REL)
        CALL F.READ(FN.CUSTOMER,Y.CUS.ID.VAL,R.CUSTOMER,F.CUSTOMER,Y.ERR.CUS)
        GOSUB JOINT.NAME.FAMILY
        Y.DES = R.RELATION<EB.REL.DESCRIPTION,1>
        Y.FORM.NAME = Y.DES:' ':Y.JOINT.NAME
        IF Y.LIST.NAME THEN
            Y.LIST.NAME := ' ':Y.FORM.NAME
        END ELSE
            Y.LIST.NAME = Y.FORM.NAME
        END
        Y.CNT += 1 ;*R22 Auto code conversion
    REPEAT

    Y.LOCAL.NAME = R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME>
    CHANGE @SM TO '' IN Y.LOCAL.NAME
    Y.FINAL.NAME =Y.LOCAL.NAME:' ':Y.LIST.NAME
    Y.LEN.VAL = LEN(Y.FINAL.NAME)
    Y.FINAL.NAME.LIST = Y.FINAL.NAME
    Y.LEN.VAL = LEN(Y.FINAL.NAME.LIST)
    IF Y.LEN.VAL GT 65 THEN
        R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME,1> = Y.FINAL.NAME.LIST[1,65]
        R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME,2> = Y.FINAL.NAME.LIST[66,65]
    END ELSE
        R.NEW(AZ.LOCAL.REF)<1,POS.BENE.NAME,1> = Y.FINAL.NAME.LIST
    END
RETURN

*------------------------------------------------------
JOINT.NAME.FAMILY:
*------------------------------------------------------

    IF R.CUSTOMER<EB.CUS.LOCAL.REF,POS.TIPO.CUS> EQ 'PERSONA FISICA' OR R.CUSTOMER<EB.CUS.LOCAL.REF,POS.TIPO.CUS> EQ 'CLIENTE MENOR' THEN
        Y.GIVEN.NAME = R.CUSTOMER<EB.CUS.GIVEN.NAMES>
        Y.FAM.NAME = R.CUSTOMER<EB.CUS.FAMILY.NAME>
        CHANGE " " TO "*" IN Y.GIVEN.NAME
        Y.VAR1.CNT = DCOUNT(Y.GIVEN.NAME,"*")
        Y.GIVEN.NAME.1 = FIELD(Y.GIVEN.NAME,"*",1,Y.VAR1.CNT-1)
        CHANGE "*" TO " " IN Y.GIVEN.NAME.1

        CHANGE " " TO "*" IN Y.FAM.NAME
        Y.VAR2.CNT = DCOUNT(Y.FAM.NAME,"*")
        Y.FAM.NAME.1 = FIELD(Y.FAM.NAME,"*",1,Y.VAR2.CNT-1)
        CHANGE "*" TO " " IN Y.FAM.NAME.1

        Y.FAM.NAME.2 = FIELD(Y.FAM.NAME,"*",Y.VAR2.CNT,1)
        Y.JOINT.NAME = Y.GIVEN.NAME.1:" ":Y.FAM.NAME.1:" ":Y.FAM.NAME.2[1,1]
    END

    IF R.CUSTOMER<EB.CUS.LOCAL.REF,POS.TIPO.CUS> EQ 'PERSONA JURIDICA' THEN
        Y.NAME.1 = R.CUSTOMER<EB.CUS.NAME.1,1>
        IF Y.NAME.1 EQ '' THEN
            Y.NAME.1 = R.CUSTOMER<EB.CUS.NAME.1,2>
        END
        Y.NAME.2 = R.CUSTOMER<EB.CUS.NAME.2,1>
        IF Y.NAME.2 EQ '' THEN
            Y.NAME.2 = R.CUSTOMER<EB.CUS.NAME.2,2>
        END
        CHANGE " " TO "*" IN Y.NAME.1
        Y.VAR2.1.CNT = DCOUNT(Y.NAME.1,"*")
        Y.NAME.1.1 = FIELD(Y.NAME.1,"*",1,Y.VAR2.1.CNT-1)
        CHANGE "*" TO " " IN Y.NAME.1.1

        CHANGE " " TO "*" IN Y.NAME.2
        Y.VAR2.2.CNT = DCOUNT(Y.NAME.2,"*")
        Y.NAME.1.2 = FIELD(Y.NAME.2,"*",1,Y.VAR2.2.CNT-1)
        CHANGE "*" TO " " IN Y.NAME.1.2

        Y.NAME.1.3 = FIELD(Y.NAME.2,"*",Y.VAR2.2.CNT,1)
        Y.JOINT.NAME = Y.NAME.1.1:' ':Y.NAME.1.2:' ':Y.NAME.1.3[1,1]

    END
RETURN
PGM.END:

END
