<%@ page import="java.util.List" %>
<%@ page import="br.com.demo.model.Phonebook" %>
<br/>
<input type="hidden" id="id" name="id"/>
<div class="col-md-12">
    <div class="form-group">
        <div class="row">
            <div class="col-sm-3">
                <strong>Name</strong>
            </div>
            <div class="col-sm-2">
                <strong>Phone</strong>
            </div>
            <div class="col-sm-2"></div>
        </div>
<%
        List<Phonebook> items = (List<Phonebook>)request.getAttribute("result");

        if(items != null && !items.isEmpty()){
            for(Phonebook item : items){
%>
            <div class="row">
                <div class="col-sm-3">
                        <%=item.getName()%>
                </div>
                <div class="col-sm-2">
                        <%=item.getPhone()%>
                </div>
                <div class="col-sm-2">
                        <button onclick="document.getElementById('id').value = <%=item.getId()%>; document.forms[0].action='edit';" class="btn btn-warning btn-sm">Edit</button>
                        <button onclick="if(confirm('Do you confirm the deletion of this item?')) { document.getElementById('id').value = <%=item.getId()%>; document.forms[0].action='delete'; }" class="btn btn-danger btn-sm">Delete</button>
                </div>
            </div>
<%
            }
        }
%>
    </div>
</div>