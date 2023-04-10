* @ValidationCode : MjotMTM1MDY0MDUyMzpDcDEyNTI6MTY4MTEyMzczNTE4NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Apr 2023 16:18:55
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.ACC.HOLDER(JOINT.NAME)
*---------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : btorresalbornoz
* Program Name  : REDO.S.GET.CUS.ACC.NAME
* ODR NUMBER    :
*----------------------------------------------------------------------------------
* Description   : Deal slip routine attached to TT to retrieve CUSTOMER name from the transaction, which
*                 depends on the application name
* In parameter  : None
* out parameter : None
*----------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 13-Jul-2010      Chandra Prakash T  ODR-2010-01-0213  Initial creation
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,++ TO +=1, = TO EQ
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.TELLER
    $INSERT I_F.RELATION
    $INSERT I_F.RELATION.CUSTOMER



    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*---------------------------
INITIALISE:
*---------------------------
    JOINT.NAME=''
    REF.POS = ''
    CONCAT1 = ''
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    R.CUSTOMER = ''
    CUSTOMER.ERR = ''
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    R.ACCOUNT.REC = ''
    Y.ACCOUNT.ERR = ''
    Y.ACCOUNT.ID = ''
    JOINT.HOLDER.VAL = ''
    CUSTOMER.ID = ''
    IS.RELATIONS.CNT = ''
    IS.RELATIONS.LIST = ''
    FN.RELATION = 'F.RELATION'
    F.RELATION = ''
    CALL OPF(FN.RELATION,F.RELATION)
    R.RELATION.REC = ''
    Y.RELATION.ERR = ''
    IS.RELATION.NO = ''
    IS.RELATION.ID = ''
    IS.RELATION.DESC = ''
    IS.CUST.NAMES = ''
    Y.FINAL.ACCT.NAME = ''
    Y.ACC.NAMES = ''
* R.ACCOUNT.HIS.REC = ''
* FN.ACCOUNT$HIS = 'F.ACCOUNT$HIS'
* F.ACCOUNT$HIS = ''

RETURN


*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------

    Y.ACCOUNT.ID = R.NEW(TT.TE.ACCOUNT.2)
    APPL.ARRAY = "CUSTOMER"
    FIELD.ARRAY = "L.CU.TIPO.CL"
    FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FIELD.ARRAY,FIELD.POS)
    LOC.L.CU.TIPO.CL.POS = FIELD.POS
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,Y.ACCOUNT.ERR)
    CUSTOMER.ID = R.ACCOUNT<AC.CUSTOMER>

    CALL F.READ(FN.CUSTOMER,CUSTOMER.ID,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ER)

    IF R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS> EQ "PERSONA FISICA" OR R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS> EQ "CLIENTE MENOR" THEN
        Y.CUS.NAMES = R.CUSTOMER<EB.CUS.GIVEN.NAMES>:" ":R.CUSTOMER<EB.CUS.FAMILY.NAME>
    END

    IF R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS> EQ "PERSONA JURIDICA" THEN ;*R22 Auto code conversion
        Y.CUS.NAMES = R.CUSTOMER<EB.CUS.NAME.1,1>:" ":R.CUSTOMER<EB.CUS.NAME.2,1>
    END
*  Y.CUS.NAMES = FMT(Y.CUS.NAMES,'R#35')
*  CUSTOMER.NAME= Y.CUS.NAMES

* IF NOT(R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS>) THEN
*     Y.CUS.NAMES = R.CUSTOMER<EB.CUS.SHORT.NAME,1>
* END

    Y.RELATION.COUNT = DCOUNT(R.ACCOUNT<AC.RELATION.CODE>,@VM)

    Y.COUNT = 1
    IF Y.RELATION.COUNT THEN
        GOSUB CHECK.NAMES
    END

*    IF NOT(Y.ACC.NAMES) THEN
*        Y.ACC.NAMES  =  Y.CUS.NAMES
*    END

*    IF VC EQ 1 THEN
**VM.COUNT = DCOUNT(Y.ACC.NAMES,FM) ;*PACS00260027 - multi value dates are not displayed becuase overriding common variable VM.COUNT
*        O.DATA = Y.ACC.NAMES<VC>
*    END ELSE

*        O.DATA =Y.ACC.NAMES<VC>
*    END





RETURN
*    ----------------------------------------------------------------------------

CHECK.NAMES:
*    -----------------------------------------------------------------------------

    LOOP
    WHILE Y.COUNT LE Y.RELATION.COUNT
        Y.CONT.FLAG = ''
*        IF Y.HIS.ACCT.ID EQ '' THEN
        RELATION.ID = R.ACCOUNT<AC.RELATION.CODE,Y.COUNT>
*        END ELSE
*            RELATION.ID = R.ACCOUNT.HIS.REC<AC.RELATION.CODE,Y.COUNT>
*        END
        IF RELATION.ID LT 500 OR RELATION.ID GT 529 THEN
            Y.COUNT += 1
            Y.CONT.FLAG = 1
        END
        IF NOT(Y.CONT.FLAG) THEN
            CALL F.READ(FN.RELATION,RELATION.ID,R.RELATION,F.RELATION,RELATION.ER)

            Y.REL.DESC = R.RELATION<EB.REL.DESCRIPTION>
*           IF Y.HIS.ACCT.ID EQ '' THEN
            CUSTOMER.ID = R.ACCOUNT<AC.JOINT.HOLDER,Y.COUNT>
*           END ELSE
*               CUSTOMER.ID = R.ACCOUNT.HIS.REC<AC.JOINT.HOLDER,Y.COUNT>
*           END
            CALL F.READ(FN.CUSTOMER,CUSTOMER.ID,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ER)

            IF R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS> EQ "PERSONA FISICA" OR R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS> EQ "CLIENTE  MENOR" THEN ;*R22 Auto code conversion
                Y.CUS.NAME = R.CUSTOMER<EB.CUS.GIVEN.NAMES>:" ":R.CUSTOMER<EB.CUS.FAMILY.NAME>
            END

            IF R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS> EQ "PERSONA JURIDICA" THEN ;*R22 Auto code conversion
                Y.CUS.NAME = R.CUSTOMER<EB.CUS.NAME.1,1>:" ":R.CUSTOMER<EB.CUS.NAME.2,1>
            END

*          IF NOT(R.CUSTOMER<EB.CUS.LOCAL.REF,LOC.L.CU.TIPO.CL.POS>) THEN
*              Y.CUS.NAME = R.CUSTOMER<EB.CUS.SHORT.NAME>
*          END
            Y.CUS.COMPL.NAME=Y.REL.DESC:': ':Y.CUS.NAME
            Y.CUS.COMPL.NAME = FMT(Y.CUS.COMPL.NAME,'R#35')
            IF JOINT.NAME EQ '' THEN
                JOINT.NAME = Y.CUS.COMPL.NAME
            END ELSE
                JOINT.NAME<-1>= Y.CUS.COMPL.NAME
            END

            Y.COUNT += 1
        END
    REPEAT
RETURN

END
