function LinkTo(Tgt) {
  var InA = document.createElementNS('http://www.w3.org/1999/xhtml', 'a');
  InA.setAttribute('href', '#' + Tgt);   // prince bug: foo.href = bar; doesn't work!
  InA.setAttribute('class', document.getElementById(Tgt).parentNode.className) ;
  
  return InA;
}

function TocItem(Tgt) {
  var InLI = document.createElementNS('http://www.w3.org/1999/xhtml', 'li');
  InLI.appendChild(LinkTo(Tgt));

  return InLI;
}

function ToCwalk(Source) {
  var InOL   = document.createElementNS('http://www.w3.org/1999/xhtml', 'ul');
  var DStack = [];

  var Walker = function(lSource) {

    switch (lSource.nodeName.toString().toUpperCase()) {
      case 'H1': if (lSource.getAttribute('id') !== 'toc') { DStack.push({d:1, t:lSource.id}); } break;
      case 'H2': if (lSource.getAttribute('notoc') !== 'notoc') { DStack.push({d:2, t:lSource.id}); } break;
//      case 'H3': if (lSource.getAttribute('notoc') !== 'notoc') { DStack.push({d:3, t:lSource.id}); } break;
//      case 'H4': if (lSource.getAttribute('notoc') !== 'notoc') { DStack.push({d:4, t:lSource.id}); } break;
//      case 'H5': if (lSource.getAttribute('notoc') !== 'notoc') { DStack.push({d:5, t:lSource.id}); } break;
//      case 'H6': if (lSource.getAttribute('notoc') !== 'notoc') { DStack.push({d:6, t:lSource.id}); } break;
      default  : break;
    }

    if (lSource.hasChildNodes()) {
      var tNode = lSource.firstChild;
      do {
        Walker(tNode);
      } while (tNode = tNode.nextSibling);
    }
  }

  Walker(Source);

  var curDepth   = 1;
  var curStack   = [InOL];
  var childStack = [];
  var lastChild  = null;

  for (var i=0, iC=DStack.length; i<iC; ++i) {
    var gap = DStack[i].d - curDepth;

    switch (gap) {
      case 0:
        lastChild = TocItem(DStack[i].t)
        curStack[curStack.length-1].appendChild(lastChild);
        break;

      case 1:
        ++curDepth;
        childStack.push(lastChild);
        var newList = document.createElementNS('http://www.w3.org/1999/xhtml', 'ul');
        curStack.push(newList);
        lastChild.appendChild(newList);
        lastChild = TocItem(DStack[i].t)
        curStack[curStack.length-1].appendChild(lastChild);
        break;

      default:
        if (gap > 0) {
          Log.error("Header depth increased by more than one!");
        } else {
          for (z=0; z>gap; --z) {
            --curDepth;
            childStack.pop();
            curStack.pop();
          }
          lastChild = TocItem(DStack[i].t)
          curStack[curStack.length-1].appendChild(lastChild);
        }
        break;
    }
  }

  return InOL;
}