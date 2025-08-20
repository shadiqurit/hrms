let gridView = apex.region('vGridmn').widget().interactiveGrid("getViews", "grid");
let columns = gridView.getColumns();
//let dnameColumn = columns.filter(column => column.elementId == 'c_dname')[0];   // filter by staticId
let dnameColumn = columns.filter(column => column.property == 'DAY1')[0];   // filter by column name 
dnameColumn.heading = 'Sun 11';
gridView.refreshColumns();
gridView.refresh();