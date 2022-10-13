<script>
    function inputHandler(masks, max, event) {
        var c = event.target;
        var v = c.value.replace(/\D/g, '');
        var m = c.value.length > max ? 1 : 0;
        VMasker(c).unMask();
        VMasker(c).maskPattern(masks[m]);
        c.value = VMasker.toPattern(v, masks[m]);
    }

    var telMask = ['(99) 9999-99999', '(99) 99999-9999'];
    var tel = document.querySelector('#phone');
    VMasker(tel).maskPattern(telMask[0]);
    tel.addEventListener('input', inputHandler.bind(undefined, telMask, 14), false);
</script>