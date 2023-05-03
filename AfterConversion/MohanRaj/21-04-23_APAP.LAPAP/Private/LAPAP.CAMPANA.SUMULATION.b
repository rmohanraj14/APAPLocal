* @ValidationCode : MjotNTQzMzY5MjgwOkNwMTI1MjoxNjgyMDc3MzAwODUxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 17:11:40
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
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
SUBROUTINE LAPAP.CAMPANA.SUMULATION
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.REDO.CAMPAIGN.TYPES
    GOSUB GET.CAMPANA.CUSTOMER
    GOSUB GET.TIPO.CAMPANA
RETURN

GET.CAMPANA.CUSTOMER:
********************
    AA.ID = COMI
    CALL APAP.LAPAP.REDO.B.CON.LNS.BY.DEBTOR.AA.RECS(AA.ID,OUT.RECORD) ;*R22 Manual Code Conversion-Call Method Format Modified
    R.AA.CUSTOMER             = FIELD(OUT.RECORD,"*",9)
RETURN
GET.TIPO.CAMPANA:
*****************
    FN.REDO.CAMPAIGN.TYPES = 'F.REDO.CAMPAIGN.TYPES'; F.REDO.CAMPAIGN.TYPES = ''
    CALL OPF(FN.REDO.CAMPAIGN.TYPES,F.REDO.CAMPAIGN.TYPES)
    Y.APPL = "AA.PRD.DES.CUSTOMER"
    Y.FLD  = "L.AA.CAMP.TY"
    Y.POS  = ""
    CALL MULTI.GET.LOC.REF(Y.APPL,Y.FLD,Y.POS)
    L.AA.CAMP.TY.POS = Y.POS<1,1>
    YL.AA.CAMP.TY = R.AA.CUSTOMER<AA.CUS.LOCAL.REF,L.AA.CAMP.TY.POS>
    ERR.REDO.CAMPAIGN.TYPES = ''; R.REDO.CAMPAIGN.TYPES = '';
    CALL F.READ(FN.REDO.CAMPAIGN.TYPES,YL.AA.CAMP.TY,R.REDO.CAMPAIGN.TYPES,F.REDO.CAMPAIGN.TYPES,ERR.REDO.CAMPAIGN.TYPES)
    IF R.REDO.CAMPAIGN.TYPES THEN
        Y.CAM.TYPE.DESC = R.REDO.CAMPAIGN.TYPES<CG.TYP.CAM.TYPE.DESC>
    END
    COMI = Y.CAM.TYPE.DESC
RETURN
END
