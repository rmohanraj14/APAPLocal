* @ValidationCode : MjozMzM1MTUzODpDcDEyNTI6MTY4MjQ5MjgyNjQyMTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Apr 2023 12:37:06
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
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ARC.PDF.CONSULT(ROU.ARGS,ROU.RESPONSE,RESPONSE.TYPE,STYLE.SHEET)
*---------------------------------------------------------------------------------
*******************************************************************************************************************
*Company   Name    : APAP
*Developed By      : Temenos Application Management
*Program   Name    : REDO.ARC.PDF.CONSULT.DETAILS
*------------------------------------------------------------------------------------------------------------------
*Description       : Generating PDF for ARC IB
*Linked With       : ARCPDF
*In  Parameter     : ENQ.DATA
*Out Parameter     : ENQ.DATA
*ODR  Number:

*MODIFICATION:
*---------------------------------------------------------------------------------
*DATE           ODR                   DEVELOPER               VERSION
*--------       ----------------      -------------           --------------------
*07.04.2011     PACS00036498           Prabhu N            INITIAL CREATION
* 11-APR-2023     Conversion tool    R22 Auto conversion       if condition added
* 11-APR-2023      Harishvikram C   Manual R22 conversion      CALL routine format modified
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_System
    $INSERT I_F.AZ.ACCOUNT
    $USING APAP.TAM


    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT'
    F.AZ.ACCOUNT  = ''
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)


    PDF.HEADER=System.getVariable('CURRENT.SCA.PDF.HEADER')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion- start
        PDF.HEADER = ""
    END					;*R22 Auto conversion- end
    PDF.DATA=System.getVariable('CURRENT.SCA.PDF.DATA')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion- start
        PDF.DATA = ""
    END					;*R22 Auto conversion- end
    PDF.FOOTER=System.getVariable('CURRENT.SCA.PDF.FOOTER')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion- start
        PDF.FOOTER = ""
    END					;*R22 Auto conversion- end

    Y.ACCT.NO = System.getVariable('CURRENT.ACCT.NO')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion - start
        Y.ACCT.NO = ""
    END					;*R22 Auto conversion - end
    CALL F.READ(FN.AZ.ACCOUNT,Y.ACCT.NO,R.AZ.ACCOUNT,F.AZ.ACCOUNT,AZ.ACCOUNT.ERR)

    CALL APAP.TAM.redoConvertAccount(Y.ACCT.NO,'',ARR.ID,ERR.TEXT) ;*Manual R22 conversion


    RESPONSE.TYPE = 'XML.ENQUIRY'
    STYLE.SHEET = '/transforms/dummy.xsl'
    Y.LEN=LEN(PDF.DATA)
    Y.RES=PDF.DATA[0,Y.LEN-3]

    XML.RECS = '<window><panes><pane><dataSection><enqResponse>'
    IF R.AZ.ACCOUNT THEN
        XML.RECS :='<r><c><cap>' : PDF.HEADER : PDF.DATA : PDF.FOOTER : '^^IMAGE=apaplogo.jpg^^PAGE=depositpodger.xsl </cap></c></r>'
    END ELSE
        IF ARR.ID THEN
            XML.RECS :='<r><c><cap>' : PDF.HEADER : PDF.DATA : PDF.FOOTER : '^^IMAGE=apaplogo.jpg^^PAGE=loanpodger.xsl </cap></c></r>'
        END ELSE
            XML.RECS :='<r><c><cap>' : PDF.HEADER : PDF.DATA : PDF.FOOTER : '^^IMAGE=apaplogo.jpg^^PAGE=savingpodger.xsl </cap></c></r>'
        END
    END
    XML.RECS :='</enqResponse></dataSection></pane></panes></window>'
    ROU.RESPONSE = XML.RECS
RETURN
END
