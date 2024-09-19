@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TDS Register Final'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@UI.headerInfo: {
    typeName: 'TDS Register',
    typeNamePlural: 'TDS Register'
}
define view entity ZUNE_TDS_FINAL 
with parameters FromDate : zune_fdate , ToDate : zune_tdate
as 
select  from I_Withholdingtaxitem as A
left outer join I_JournalEntry as B on A.AccountingDocument = B.AccountingDocument and A.FiscalYear=B.FiscalYear
left outer join I_Supplier as C on A.CustomerSupplierAccount = C.Supplier
left outer join I_SupplierInvoiceAPI01 as D on B.DocumentReferenceID = D.SupplierInvoiceIDByInvcgParty and A.FiscalYear=D.FiscalYear and A.CustomerSupplierAccount=D.InvoicingParty
left outer join I_Extendedwhldgtaxcode as E on E.WithholdingTaxType = A.WithholdingTaxType and E.WithholdingTaxCode = A.WithholdingTaxCode
left outer join I_ExtendedWhldgTaxCodeText as F on F.WithholdingTaxType = A.WithholdingTaxType and F.WithholdingTaxCode = A.WithholdingTaxCode and F.Language='E'
{
    key A.AccountingDocument as DocumentNumber,
    key A.WithholdingTaxCode,
    key A.WithholdingTaxType,
    key E.OfficialWhldgTaxCode, 
    A.WithholdingTaxPercent ,
    cast(A.WhldgTaxAmtInTransacCrcy as abap.dec( 13, 2 )) as Amount,
    cast(A.WhldgTaxBaseAmtInTransacCrcy as abap.dec( 13, 2 )) as  BaseAmount,
    A.GLAccount,
    A.CustomerSupplierAccount,
    B.DocumentReferenceID ,
    B.DocumentDate,
    B.PostingDate,
    C.BusinessPartnerPanNumber, 
    F.WhldgTaxCodeName,
    C.SupplierFullName,
    C.Supplier
}
where B.PostingDate between $parameters.FromDate and $parameters.ToDate and A.DownPaymentIsCleared <> 'X'
