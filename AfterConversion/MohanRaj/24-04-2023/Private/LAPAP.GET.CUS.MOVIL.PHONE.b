* @ValidationCode : MjotMTMzOTc0NjE2OkNwMTI1MjoxNjgyMzE1MDQ5ODM0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Apr 2023 11:14:09
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
$PACKAGE APAP.LAPAP
*Modification history
*Date                Who               Reference                  Description
*24-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM
*24-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.GET.CUS.MOVIL.PHONE

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.CUSTOMER

    FN.CUSTOMER    = 'F.CUSTOMER' ;
    F.CUSTOMER     = '';
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    Y.CUS.ID = O.DATA

    Y.TEL.CASA = '';
    Y.TEL.CEL  = '';
    Y.NUMERO.TELEFONO = '';

    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)

    IF R.CUSTOMER THEN

        LREF.FIELD = 'L.CU.TEL.TYPE':@VM:'L.CU.TEL.AREA':@VM:'L.CU.TEL.NO'
        CALL MULTI.GET.LOC.REF('CUSTOMER',LREF.FIELD,LREF.POS)

        TEL.TYPE.POS         = LREF.POS<1,1>
        L.CU.TEL.AREA.POS    = LREF.POS<1,2>
        L.CU.TEL.NO.POS      = LREF.POS<1,3>

        TEL.TYPE.ID         = R.CUSTOMER<EB.CUS.LOCAL.REF,TEL.TYPE.POS>
        Y.TEL.AREA          = R.CUSTOMER<EB.CUS.LOCAL.REF,L.CU.TEL.AREA.POS>
        Y.TEL.NUM           = R.CUSTOMER<EB.CUS.LOCAL.REF,L.CU.TEL.NO.POS>

        TEL.TYPE.ID  = CHANGE(TEL.TYPE.ID,' ',@FM);
        TEL.TYPE.ID  = CHANGE(TEL.TYPE.ID,@SM,@FM)
        TEL.TYPE.ID  = CHANGE(TEL.TYPE.ID ,@VM,@FM)

        Y.TEL.AREA  = CHANGE(Y.TEL.AREA,' ',@FM);
        Y.TEL.AREA  = CHANGE(Y.TEL.AREA,@SM,@FM)
        Y.TEL.AREA  = CHANGE(Y.TEL.AREA ,@VM,@FM)

        Y.TEL.NUM = CHANGE(Y.TEL.NUM,' ',@FM);
        Y.TEL.NUM  = CHANGE(Y.TEL.NUM,@SM,@FM)
        Y.TEL.NUM  = CHANGE(Y.TEL.NUM ,@VM,@FM)

        LOCATE "06" IN TEL.TYPE.ID SETTING POS.FIELD THEN
            Y.TEL.CEL = Y.TEL.AREA<POS.FIELD>:'':Y.TEL.NUM<POS.FIELD>
        END

        LOCATE "01" IN TEL.TYPE.ID SETTING POS.FIELD.2 THEN
            Y.TEL.CAS = Y.TEL.AREA<POS.FIELD.2>:'':Y.TEL.NUM<POS.FIELD.2>
        END

    END

    IF Y.TEL.CEL NE '' THEN
        Y.NUMERO.TELEFONO = Y.TEL.CEL
    END ELSE
        Y.NUMERO.TELEFONO = Y.TEL.CASA
    END

    O.DATA = Y.NUMERO.TELEFONO

END
