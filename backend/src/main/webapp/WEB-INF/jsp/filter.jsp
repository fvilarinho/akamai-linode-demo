<div class="col-md-12">
    <div class="form-group">
        <div class="row">
            <label for="q">Name</label>
            <div class="col-sm-3">
                <input type="text" id="q" name="q" class="form-control" value="${q}"/>
                <small id="qHelp" class="form-text text-muted">Type the name you want to find.</small>
            </div>
            <div class="col-sm-2">
                <button type="submit" class="btn btn-primary">Filter</button>
                <button onclick="document.forms[0].action = 'add';" class="btn btn-primary">Add</button>
            </div>
        </div>
    </div>
</div>