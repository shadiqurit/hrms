$('#P36_TYP').on('change', function() {
    $val = apex.item('P36_TYP').getValue();
    if ($val == 'Region') {
        $('label[for=P902_SITE_ENG],#P902_SITE_ENG,#P902_SITE_ENG_lov_btn').show();
        $('label[for=P902_FROM_DATE],#P902_FROM_DATE,#P902_FROM_DATE_lov_btn,label[for=P902_TO_DATE],#P902_TO_DATE,#P902_TO_DATE_lov_btn,label[for=P902_PROJECT],#P902_PROJECT,#P902_PROJECT_lov_btn,label[for=P902_SITE],#P902_SITE,#P902_SITE_lov_btn').hide();
    } else if ($val == 'Zone') {
        $('label[for=P902_SITE_ENG],#P902_SITE_ENG,#P902_SITE_ENG_lov_btn,label[for=P902_FROM_DATE],#P902_FROM_DATE,#P902_FROM_DATE_lov_btn,label[for=P902_TO_DATE],#P902_TO_DATE,#P902_TO_DATE_lov_btn').show();
        $('label[for=P902_PROJECT],#P902_PROJECT,#P902_PROJECT_lov_btn,label[for=P902_SITE],#P902_SITE,#P902_SITE_lov_btn').hide();        
    } else if ($val == 'Area') {
        $('label[for=P902_SITE_ENG],#P902_SITE_ENG,#P902_SITE_ENG_lov_btn,label[for=P902_FROM_DATE],#P902_FROM_DATE,#P902_FROM_DATE_lov_btn,label[for=P902_TO_DATE],#P902_TO_DATE,#P902_TO_DATE_lov_btn').show();
        $('label[for=P902_PROJECT],#P902_PROJECT,#P902_PROJECT_lov_btn,label[for=P902_SITE],#P902_SITE,#P902_SITE_lov_btn').hide();  
    } else {
        null;
    }
});