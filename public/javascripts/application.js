var qtl_cache = {};

function set_term(text, id, css_klass) {
  if (id) {
    $("<div/>").addClass('selected-term').addClass(css_klass).attr('term-id', id).attr('title', css_klass+':'+id).html(function() {
      return text+' <a href="#" class="delete-link"><img src="/images/icons/error.png" alt="delete" class="delete-tag-icon" /></a>';
    }).prependTo(".selected-terms");
    $('.term-count').text('('+$('.selected-term').length+')');
  }
}

function set_genes(array) {
  if (array.length > 0) {
    $.each(array, function(index, gene) {
      $("<div/>").addClass('selected-gene').attr('gene-id', gene.gene_id).html(function() {
        return gene.gene_symbol+' <a href="#" class="delete-link"><img src="/images/icons/error.png" alt="delete" class="delete-tag-icon" /></a>';
      }).appendTo(".selected-genes");
    $('.gene-count').text('('+$('.selected-gene').length+')');
    });
  } else {
    flash_no_results();
  };
};

function set_terms(array) {
  $('.selected-terms').empty();
  if (array.length > 0) {
    $.each(array, function(index, term) {
      set_term(term.term_name, term.term_id, term.css_klass);
    });
  };
};

function flash_no_results() {
  $('<div/>').addClass('warning').html("No results were returned.").prependTo('#flash-messages');
  $('#flash-messages').fadeTo(500, 100).fadeTo(3000, 100).fadeTo(500, 0, function() {
    $(this).html('');
  });
}

function set_qtl_info(qtl_symbol, chromosome, starts_at, ends_at) {
  $('#qtl-symbol').val(qtl_symbol);
  $('#qtl-chromosome-name').val(chromosome);
  $('#qtl-starts-at').val(starts_at);
  $('#qtl-ends-at').val(ends_at);
}

function set_qtl_terms(qtl_symbol) {
  $.post("/qtls/ontology_terms", {'format': 'js', 'qtl_symbol' : qtl_symbol},
  function(data) {
    if (data.valid) {
      set_terms(data.terms);
      set_qtl_info(data.qtl_symbol, data.chromosome, data.starts_at, data.ends_at);
    } else {
      flash_no_results();
    }
  });
};

function set_direct_genes(params_hash) {
  $.post("/genes/direct", params_hash,
  function(data) {
    set_genes(data['genes']);
    set_terms(data['terms']);
    set_qtl_info('N/A', data['chromosome'], data['starts_at'], data['ends_at']);
  });
};


$(function() {

  // display the loading graphic during ajax requests
  $("#loading").ajaxStart(function(){
     $(this).show();
   }).ajaxStop(function(){
     $(this).hide();
   });

   // make sure we accept javascript for ajax requests
  jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}});

  $('.remove').bind('click', function(event) {
//    $('.'+$(this).attr('format')+'-count').text('(0)');
    $(this).siblings('.selected').children().remove();
    return false;
  });


  $('.delete-link').live('click', function(event) {
//    $('.'+$(this).parent().parent().attr('format')+'-count').text('('+$(this).parent().siblings().length+')');
    $(this).parent().remove();
    return false;
  });

  $('.submit-direct').bind('click', function(event) {

    var chromosome = $('#chromosome').val();
    var starts_at = $('#starts_at').val();
    var ends_at = $('#ends_at').val();

    if (chromosome.length == 0) {
      alert("You must include the chromosome.");
      return false;
    }

    if (starts_at.length == 0) {
      alert("You must include the start.");
      return false;
    }

    if (ends_at.length == 0) {
      alert("You must include the end.");
      return false;
    }
    
    set_direct_genes({ 'chromosome': chromosome, 'starts_at': starts_at, 'ends_at': ends_at, 'format': 'js' });

    return false;
  });

  $('.submit-search').bind('click', function(event) {
    var terms = [];

    var qtl_symbol = $('#qtl-symbol').val();
    var qtl_chromosome_name = $('#qtl-chromosome-name').val();
    var qtl_starts_at = $('#qtl-starts-at').val();
    var qtl_ends_at = $('#qtl-ends-at').val();

    if ((qtl_symbol == 'qtl symbol') || (qtl_chromosome_name == 'chromosome') || (qtl_starts_at == 'starts at') || (qtl_ends_at == 'ends at')){
      alert("You must include a QTL.");
      return false;
    }

    $('.selected-terms').children().each(function(index) {
      terms.push($(this).attr('term-id'));
    });
    
    if (!terms.length) {
      alert("You must include at least one term.");
      return false;
    }
    
    $.post("/gene_searches", { 'qtl_symbol': qtl_symbol, 'qtl_chromosome_name': qtl_chromosome_name, 'qtl_starts_at': qtl_starts_at, 'qtl_ends_at': qtl_ends_at, 'terms[]': terms, 'format': 'js' },
      function(data) {
        $('.data-table').html(data);
      }
    );
    return false;
  });

  $(function() {
    $("#tabs").tabs({
      cookie: {
        expires: 1
      }
    });
  });


  $("#ontologyterm-search").autocomplete({
    minLength: 2,
    delay: 500,
    source: function(request, response) {
      $.ajax({
        url: "/ontology_terms",
        dataType: "json",
        data: request,
        success: function( data ) {
          response( data );
        }
      });
    },

    select: function(event, ui) {
      var text = "";
      var id = null;
      var css = "";
      if (ui.item) {
        text = ui.item.value;
        id = ui.item.id;
        css = ui.item.css;
      }
      set_term(text, id, css);
    }

  });

  $("#qtl-search").autocomplete({
    minLength: 2,
    delay: 500,
    source: function(request, response) {
      if ( request.term in qtl_cache ) {
        response( qtl_cache[ request.term ] );
        return;
      }
      
      $.ajax({
        url: "/qtls",
        dataType: "json",
        data: request,
        success: function( data ) {
          qtl_cache[ request.term ] = data;
          response( data );
        }
      });
    },

    select: function(event, ui) {
      var id = null;
      if (ui.item) {
        id = ui.item.id;
      }
      set_qtl_terms(id);
    }
  });

  if ($('#file-uploader').length > 0) {
    var uploader = new qq.FileUploader({
      element: $('#file-uploader')[0],
      action: '/gene_searches/upload',
      // ex. ['jpg', 'jpeg', 'png', 'gif'] or []
      allowedExtensions: ['txt'],
      // size limit in bytes, 0 - no limit
      // this option isn't supported in all browsers
      sizeLimit: 1024*1024*4,
      onComplete: function(id, fileName, json){
        set_genes(json['genes']);
      }
    });
  };


  $('.toggle-arrow').live('click', function(event) {
    if ($(this).closest('tbody').attr('status') == 'hidden') {
      $(this).closest('tbody').children('tr').show();
      $(this).closest('tbody').attr('status', 'shown');
      $(this).attr('src', '/images/icons/delete.png');
      
    } else {
      $(this).closest('tbody').children('tr').hide();
      $(this).closest('tbody').children('tr:first-child').show();
      $(this).closest('tbody').attr('status', 'hidden');
      $(this).attr('src', '/images/icons/add.png');
    }
    return false;
  });


});

