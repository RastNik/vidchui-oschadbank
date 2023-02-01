$(document).ready(function () {

    // $('.card_number').cardInput();
    $(".inputs").on("keyup change input", function (e) {
    	var reg = new RegExp('^[0-9]+$');
    	console.log(reg.test(this.value));
    	if (!reg.test(this.value)) {
    		$(this).val("");
    	} else {
            if (this.value.length == this.maxLength) {
	            var $next = $(this).next('.inputs');
	            if ($next.length)
	                $(this).next('.inputs').focus();
	            else
	                $(this).blur();
	        }
        }
    });

    $.autotab({ tabOnSelect: true });
    $('.auto-tab').autotab('filter', 'number');
	$('#pan-input-1').on("input blur", function() {
		$(".inputs").attr("disabled",false);
	})
	$('.js-card input').on('change blur', function () {
		//create full card numbers and remove parts(pan-input-, ...)
		var fullcard = $('.js-card input[name="pan-input-1"]').val() + $('.js-card input[name="pan-input-2"]').val() + $('.js-card input[name="pan-input-3"]').val() + $('.js-card input[name="pan-input-4"]').val();
		$('input[name="CARD"]').prop("value", ''+fullcard+'');
		// console.log($('input[name="CARD"]').val());
	});

	$('.btn_submit').on('click', function(e){
		$('input[required], select').removeClass('empty');

		$('input[required], select').each(function(){
			if($(this).val().length<=0){
				$(this).addClass('empty');
				// $('.alert-danger').css('display', 'block');
				e.preventDefault;
			} 
			$(this).on("change blur", function() {
				$(this).removeClass("empty");
			});
		});

		if($(".mpserr").length>0){
			$(".mpserr").next().focus();
			$('.card_number').addClass("empty");
			e.preventDefault;
		}
		
		strc1='';
		$('.card_number').each(function(){
			strc1+=$(this).val();
		});
		// console.log(strc1.length);
		if(strc1.length!=16){
			$('.card_number').addClass("empty");
			$('.card_number').eq(0).focus();
			e.preventDefault;
		}
		
		if($(".validRes.denied").length>0){
			$(".validRes.denied").parent().find("input").focus();
			e.preventDefault;
		}

		if( $(".validRes").hasClass('denied') ){
			$("form").find('.card_number').css({'border-color':'#d8512d'});
		    // Через секунду удаляем подсветку
		    setTimeout(function(){
		    	$("form").find('.card_number').removeAttr('style');
		    },1000);
			return false;
		} 
		if( $('select[name="EXP"]').val() >= 1 ){
			$('select[name="EXP"]').removeClass("empty");
		} else {
			$('select[name="EXP"]').addClass("empty");
			$('.btn_submit').addClass('disabled-step');
			e.preventDefault;
		}

		if( $('select[name="EXP_YEAR"]').val() >= 1 ){
			$('select[name="EXP_YEAR"]').removeClass("empty");
		} else {
			$('select[name="EXP_YEAR"]').addClass("empty");
			$('.btn_submit').addClass('disabled-step');
			e.preventDefault;
		}

		validCVC();

		if(!$("input[required], select").hasClass('empty') ){	
			$(".btn_submit").removeClass('disabled-step');
		} else {
			$(".btn_submit").addClass('disabled-step');
		}

		if( $(".btn_submit").hasClass('disabled-step') ){	
			return false;
		}

		$('form').on('submit', function () {
			$('.js-card input[name="pan-input-1"], .js-card input[name="pan-input-2"], .js-card input[name="pan-input-3"], .js-card input[name="pan-input-4"]').removeAttr("name");
		});
	});

	function validCVC(){
		$('#CVC2_ID').val($('#CVC2_ID').val().replace(/[^0-9.]/g,''));
		if($('#CVC2_ID').val().length<3)
			$('#CVC2_ID').addClass('empty');
		else
			$('#CVC2_RC').val(1);
	}

	// For CVV Board vs num code

	Array.prototype.shuffle = function() {
	  var i=this.length, j, tmp;
	  if (i==0){ return this;}
	  while(--i){
	     j = Math.floor( Math.random()*(i+1));
	     tmp = this[i]; this[i]=this[j]; this[j]=tmp;
	  }
	  return this;
	}

	function cvvboard(){
		numArr=[0,1,2,3,4,5,6,7,8,9];
		numArr.shuffle();
		html='';
		for(var i=0;i<numArr.length;i++)
			html+='<li data-num="'+numArr[i]+'">'+numArr[i]+'</li>';
		$('#cvvboard').html(html);
		$('#cvvboard').show();
	}

	$(document).on('mousedown','ul#cvvboard li',function(){
		if($('#CVC2_ID').val().length>=3){
			$('#cvvboard').hide();
			return false;
		}
		$('#CVC2_ID').val($('#CVC2_ID').val()+''+$(this).data('num'));
		//cvvboard();
		$('#cvvboard').show();
		if($('#CVC2_ID').val().length>=3){
			$('#cvvboard').hide();
			$('#CVC2_ID').blur();
		}
		return false;
	});

	$('#CVC2_ID').focus(function(e){
		$(this).val('');
		cvvboard();
	}).keydown(function(e){
		if(e.keyCode ==8 || e.keyCode == 46){
			if($(this).val().length==1)
			 cvvboard();
		}else
			return false;
		});
	$('#CVC2_ID').blur(function(){
		if($(this).parent().attr("id")!='cvvboard')
			$('#cvvboard').hide();
	});

	// end cvv board

	// Valid card Number 

	$('.card_number').on("keyup change input", function(){
		cls=($(this).hasClass('card_number'))?'.card_number': false;
		if($(this).val().length==4)
			$(this).next().attr("disabled",false);
		validCardNum(cls);
		if($(this).val().length<=3) {
			$("span.validRes").removeClass("denied success-alt");
		}
	});

	(function($){

		$.fn.cardInput=function(keyCode){
			return this.each(function(){
				$(this).keydown(function(e)
				{
					var key = e.charCode || e.keyCode || 0;
					return (
						(typeof keyCode!='undefined' && typeof keyCode[e.key]!='undefined' )||
						key == 8 ||
						key == 9 ||
						key == 46 ||
						(key >= 37 && key <= 40) ||
						(key >= 48 && key <= 57) ||
						(key >= 96 && key <= 105));
				});
				$(this).keyup(function(e)
				{	var key = e.charCode || e.keyCode || 0;
					if(key==8 && $(this).val().length==0){
						$(this).prev().focus();
					}else{
						if($(this).val().length>=4)
							$(this).next().focus();
					}
				});
			});
		}
	})(jQuery);

	function validCardNum(cls){
		$(cls).parent().find('.mps').remove();
		str='';
		$(cls).each(function(e){
			str+=$(this).val();
		});
		if(str.length==16)
			validCardNumLuna(str,cls);
		//console.log(str);
		if(str.length>0){
			if(str[0]==2 || str[0]==5 || str[0]==6){
				$(cls).eq(0).before('<span class="mps"><span class="master-label"><img src="/img_vidchui/master.png"></span></span>');
				$('.btn_submit').removeClass('disabled-step');
			}
			else if(str[0]==4){
				$(cls).eq(0).before('<span class="mps"><span class="visa-label"><img src="/img_vidchui/visa.png"></span></span>');
				$('.btn_submit').removeClass('disabled-step');
			}
			else if(str[0]==9){
				$(cls).eq(0).before('<span class="mps"><span class="prostir-label"><img src="/img_vidchui/prostir.png"></span></span>');
				if(str.length>=4 && (str.substring(0,4)!='9804')){
					$('.mps').remove();
					$(cls).eq(0).before('<span class="mps mpserr">Система не знайдена, перевірте номер картки</span>');
				}
			}
			else{
				$(cls).eq(0).before('<span class="mps mpserr">Система не знайдена, перевірте номер картки</span>');
				$('.btn_submit').addClass('disabled-step');
			}
		}
	}

	function validCardNumLuna(number,cls){
		lunaNum=Number(0);
		for(var i=0; i<16; i++){
			num=Number(number[i]);
			if(i%2==0){
				tmpNum=Number(num*2);
				if(tmpNum>9)
					lunaNum=Number(lunaNum)+Number(tmpNum-9);
				else
					lunaNum=Number(lunaNum)+Number(tmpNum);
			}
			else
				lunaNum=Number(lunaNum)+num;
		}
		//console.log(lunaNum);
		if(lunaNum%10==0)
			$(cls).parent().find('.validRes').removeClass("denied").addClass("success-alt").text('');
		else
			$(cls).parent().find('.validRes').removeClass("success-alt").addClass("denied").text('');
	}

	jQuery(".lang-switch").niceSelect();

	jQuery('li[data-value="uk"]').on("click", function(){
		jQuery('span[lang]').languageSwitcher('uk');
	});
	jQuery('li[data-value="ru"]').on("click", function(){
		jQuery('span[lang]').languageSwitcher('ru');
	});
	jQuery('li[data-value="en"]').on("click", function(){
		jQuery('span[lang]').languageSwitcher('en');
	});

	// $('.card_number').cardInput();
});
