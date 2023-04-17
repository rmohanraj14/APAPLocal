* @ValidationCode : MjotMTI0NjYwMzQ1OTpDcDEyNTI6MTY4MTczMzkxOTk4NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:48:39
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
SUBROUTINE REDO.V.INP.SUNNEL.UPDATE
*-----------------------------------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN Parameter    : NA
* OUT Parameter   : NA
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RIYAS
* PROGRAM NAME : REDO.V.INP.SUNNEL.UPDATE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 27-AUG-2011      Riyas               R35          Initial creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    IF Condition Added,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.VERSION
    $INSERT I_F.TELLER
    $INSERT I_GTS.COMMON
    $INSERT I_System
    $INSERT I_REDO.TELLER.PROCESS.COMMON
    $INSERT I_F.REDO.SUNNEL.CARD.DETAILS
    FN.SUNNEL.DETAILS = 'F.REDO.SUNNEL.CARD.DETAILS'
    F.SUNNEL.DETAILS  = ''
    CALL OPF(FN.SUNNEL.DETAILS,F.SUNNEL.DETAILS)
    LREF.APP = 'TELLER'
    LREF.POS = ''
    LREF.FIELDS='L.TT.CR.CARD.NO':@VM:'L.TT.AC.STATUS':@VM:'L.TT.CR.ACCT.NO'
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    Y.CARD.NO.POS      = LREF.POS<1,1>
    Y.CARD.ACCT.ST.POS = LREF.POS<1,2>
    Y.CR.ACCT.NO.POS   = LREF.POS<1,3>
    Y.ACCT = R.NEW(TT.TE.LOCAL.REF)<1,Y.CR.ACCT.NO.POS>
    VAR.CARD.NO = R.NEW(TT.TE.LOCAL.REF)<1,Y.CARD.NO.POS>
    Y.ACCT.NO   = ''
    Y.CARD.TYPE = ''
    CALL F.READ(FN.SUNNEL.DETAILS,Y.ACCT,R.SUNNEL.DETAILS,F.SUNNEL.DETAILS,SUNNEL.ERR)
    IF NOT(R.SUNNEL.DETAILS) THEN
        Y.PRESENT.CARD.ID = System.getVariable("CURRENT.CARD.NO")
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
            Y.PRESENT.CARD.ID = ""
        END ;*R22 Auto code conversion-END

        CALL REDO.GET.CARD.TYPE(Y.PRESENT.CARD.ID,Y.ACCT,Y.CARD.TYPE)
        R.SUNNEL.DETAILS<SUN.CARD.TYPE> = Y.CARD.TYPE
        CALL F.WRITE(FN.SUNNEL.DETAILS,Y.ACCT,R.SUNNEL.DETAILS)
    END
RETURN
END
