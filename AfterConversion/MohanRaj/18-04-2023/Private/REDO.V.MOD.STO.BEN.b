* @ValidationCode : MjoxNDE4NTc2Mjk1OkNwMTI1MjoxNjgxODEyNTE3MzA0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 15:38:37
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
SUBROUTINE REDO.V.MOD.STO.BEN
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.MOD.STO.BEN
*---------------------------------------------------------------------------------

*DESCRIPTION       :It is attached as authorization routine in all the version used
*                  in the development N.83.It will fetch the value from sunnel interface
*                  and assigns it in R.NEW
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BENEFICIARY
    $INSERT I_System



    GOSUB OPEN.PARA

RETURN
*---------
OPEN.PARA:
*---------

    FN.CUS.BEN.LIST = 'F.CUS.BEN.LIST'
    F.CUS.BEN.LIST  = ''
    CALL OPF(FN.CUS.BEN.LIST,F.CUS.BEN.LIST)
    OWN.BEN.FLAG = ''
    OTHER.BEN.FLAG = ''
    BEN.ACCT.NO = R.NEW(ARC.BEN.BEN.ACCT.NO)
    APP.BEN = 'BENEFICIARY'
    APP.FLD = 'L.BEN.ACCOUNT'
    BEN.APP.POS = ''
    CALL MULTI.GET.LOC.REF(APP.BEN,APP.FLD,BEN.APP.POS)
    L.BEN.ACC=BEN.APP.POS<1,1>
    OTHER.BANK.BEN = R.NEW(ARC.BEN.LOCAL.REF)<1,L.BEN.ACC>


    BEGIN CASE
        CASE PGM.VERSION EQ ',AI.REDO.MOD.OTHER.BANK.BEN'
            OWN.BEN.FLAG = 1
        CASE PGM.VERSION EQ ',AI.REDO.MOD.OWN.BANK.BEN'
            OTHER.BEN.FLAG = 1
        CASE PGM.VERSION EQ ',AI.REDO.MODIFY.THIRDPARTY'
            TP.BEN.FLAG = 1
    END CASE

    GOSUB LOOK.FOR.MODIFICATION
RETURN

*------------------
LOOK.FOR.MODIFICATION:
*------------------


    ID.BEN.TO.DEL = ''
    ID.ACCT.TO.DEL=''

    IF OWN.BEN.FLAG THEN
        ID.BEN.TO.DEL = ID.NEW
        ID.ACCT.TO.DEL=R.NEW(ARC.BEN.BEN.ACCT.NO)
        FINAL.ID.DEL = ID.ACCT.TO.DEL:"*":ID.BEN.TO.DEL
        Y.FLAG = ''
        CALL AI.REDO.CHECK.STO.TRANSFER(ID.BEN.TO.DEL,Y.FLAG)
        IF Y.FLAG EQ '1' THEN
            ETEXT ='EB-DEL.BENEFICIARY.STO'
            CALL STORE.END.ERROR
        END
    END

    IF OTHER.BEN.FLAG THEN
        ID.BEN.TO.DEL = ID.NEW
        ID.ACCT.TO.DEL = OTHER.BANK.BEN
        FINAL.ID.DEL = ID.ACCT.TO.DEL:"*":ID.BEN.TO.DEL
        Y.FLAG = ''
        CALL AI.REDO.CHECK.STO.TRANSFER(ID.BEN.TO.DEL,Y.FLAG)

        IF Y.FLAG EQ '1' THEN
            ETEXT ='EB-DEL.BENEFICIARY.STO'
            CALL STORE.END.ERROR
        END
    END


RETURN
END
