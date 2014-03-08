class @Spritz
  getSelectionText: () ->
    text = ""
    if window.getSelection
      selection = window.getSelection()
      if selection.rangeCount
        container = document.createElement("div")
        for i in [0..selection.rangeCount - 1]
          container.appendChild(selection.getRangeAt(i).cloneContents())
        text = container.innerText or container.textContent
    else if document.selection
      if document.selection.type is "Text"
        text = document.selection.createRange().text
    if text is ""
      return false
    else
      return text
  constructor: () ->
    @rootDiv = document.createElement("div")
    @rootDiv.id = "spritz_root"
    @rootDiv.align = "center"
    @rootDiv.style.position = "fixed"
    @rootDiv.style.zIndex = "999"
    @rootDiv.style.width = "400px"
    @rootDiv.style.left = "50%"
    @rootDiv.style.marginLeft = "-200px"
    @rootDiv.style.backgroundColor = "white"
    @rootDiv.style.borderColor = "black"
    @rootDiv.style.borderStyle = "solid"
    @resultDiv = document.createElement("div")
    @resultDiv.id = "spritz_result"
    @rootDiv.appendChild(@resultDiv)
    @formerSpan = document.createElement("span")
    @formerSpan.id = "spritz_former"
    @formerSpan.style.fontSize = "32px"
    @formerSpan.style.fontFamily = "Droid Sans Mono"
    @resultDiv.appendChild(@formerSpan)
    @pivotSpan = document.createElement("span")
    @pivotSpan.id = "spritz_pivot"
    @pivotSpan.style.fontSize = "32px"
    @pivotSpan.style.fontFamily = "Droid Sans Mono"
    @pivotSpan.style.color = "red"
    @resultDiv.appendChild(@pivotSpan)
    @latterSpan = document.createElement("span")
    @latterSpan.id = "spritz_latter"
    @latterSpan.style.fontSize = "32px"
    @latterSpan.style.fontFamily = "Droid Sans Mono"
    @resultDiv.appendChild(@latterSpan)
    @wpmSelectLabel = document.createElement("label")
    @wpmSelectLabel.id = "spritz_wpmlabel"
    @wpmSelectLabel.innerHTML = "WPM:"
    @rootDiv.appendChild(@wpmSelectLabel)
    @wpmSelect = document.createElement("select")
    @wpmSelect.id = "spritz_wpm"
    for wpm in [200..1000] by 50
      wpmOption = document.createElement("option")
      wpmOption.text = wpm
      @wpmSelect.add(wpmOption)
    @rootDiv.appendChild(@wpmSelect)
    @startButton = document.createElement("button")
    @startButton.id = "spritz_start"
    @startButton.onclick = () ->
      spritz.go()
    @startButton.innerHTML = "Start"
    @rootDiv.appendChild(@startButton)
    @closeButton = document.createElement("button")
    @closeButton.id = "spritz_close"
    @closeButton.onclick = () ->
      spritz.hide()
    @closeButton.innerHTML = "Close"
    @rootDiv.appendChild(@closeButton)
    @running = false
  show: () ->
    if document.body.firstChild
      document.body.insertBefore(@rootDiv, document.body.firstChild)
    else
      document.body.appendChild(@rootDiv)
  hide: () ->
    document.body.removeChild(@rootDiv)
  getWPM: () ->
    selectedIndex = @wpmSelect.selectedIndex
    wpm = @wpmSelect.options[selectedIndex].text
    return parseInt(wpm)
  setWord: (word) ->
    pivotIndex = 0
    if word.length > 1
      pivotIndex = word.length / 2 - 1 # Take the floor to make an odd length word more right heavy
    pivot = word.charAt(pivotIndex)
    @pivotSpan.innerHTML = pivot
    latter = ""
    if word.length > 1
      latter = word.slice(pivotIndex + 1, word.length)
    former = ""
    if word.length > 2
      former = word.slice(0, pivotIndex)
    if former.length > latter.length
      while former.length > latter.length
        latter += "\u00A0"
    else if latter.length > former.length
      while latter.length > former.length
        former = "\u00A0" + former
    @formerSpan.innerHTML = former
    @latterSpan.innerHTML = latter
  go: () ->
    selection = @getSelectionText()
    if not selection or selection.length is 0
      alert("Please select text to Spritz")
      return
    @running = true
    words = selection.split(/\s+/)
    currentWordIndex = 0
    callback = () =>
      if currentWordIndex < words.length
        @setWord(words[currentWordIndex++])
      else
        clearInterval(intervalId)
        @running = false
    wpm = @getWPM()
    intervalId = setInterval(callback, 60000 / wpm)
spritz = new Spritz()
spritz.show()
spritz.setWord("CoffeeSpritz")