unit untChrom_Helper;

interface

uses System.SysUtils, System.StrUtils, Winapi.Windows,
  ceflib;

procedure AddEagleToDownloaList(const document: ICefDomDocument);

implementation

type
  TElementNameVisitor = class(TCefDomVisitorOwn)
  private
    FName: string;
  protected
    procedure visit(const document: ICefDomDocument); override;
  public
    constructor Create(const AName: string); reintroduce;
  end;
{ TDOMElementNameVisitor }

constructor TElementNameVisitor.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

procedure TElementNameVisitor.visit(const document: ICefDomDocument);

  procedure ProcessNode(ANode: ICefDomNode);
  var
    Node: ICefDomNode;
  begin
    if Assigned(ANode) then
    begin
      Node := ANode.FirstChild;
      while Assigned(Node) do
      begin
        if Node.GetElementAttribute('name') = FName then
        begin
          // do what you need with the Node here
//          ShowMessage(Node.GetElementAttribute('value'));
        end;
        ProcessNode(Node);
        Node := Node.NextSibling;
      end;
    end;
  end;
begin
  ProcessNode(document.Body);
end;


function FindNodeByAttrExStarts(ANode: ICefDomNode; NodeName, AttrName,
  AttrValue: string): ICefDomNode;
var
  I: Integer;
  child: ICefDomNode;
  str: string;
begin
  Result := nil;
  if ANode = nil then
    Exit;
  OutputDebugString(PChar('FindNodeByAttrEx: ' + NodeName + '_' +  AttrName + '_' +  AttrValue + ' in ' +  ANode.Name + ':' + ANode.GetElementAttribute('class')));
  if Sametext(ANode.Name, NodeName) then
  begin
    if AttrName.IsEmpty then
      Result := ANode
    else if SameText(AttrName, 'class') then
    begin
      if SameText(ANode.GetElementAttribute('class'), AttrValue) then
        Result := ANode;
    end
    else // для иных атрибутов
    begin
      str := ANode.GetElementAttribute(AttrName);
      if AttrValue.IsEmpty or StartsText(AttrValue, str) then
        Result := ANode
    end
  end;
  if not Assigned(Result) and ANode.HasChildren then
  begin
    child := ANode.FirstChild;
      while Assigned(child) do
      begin
        Result := FindNodeByAttrExStarts(child, NodeName, AttrName, AttrValue);
        if Result <> nil then
          Exit;
        child := child.NextSibling;
      end;
  end;
end;

procedure AddEagleToDownloaList(const document: ICefDomDocument);
var
  node: ICefDomNode;
begin
  node := FindNodeByAttrExStarts(document.Body, 'div', 'class', 'eagle-player-series');
  OutputDebugString(PChar('Seaech eagle-player-series: ' + IntToHex(Integer(node), 8)));

//  node := FindNodeByAttrExStarts((AEwb.Document as IHTMLDocument3).documentElement,
//  if node <> nil then
//  begin
//    for I := 0 to (node.children as IHTMLElementCollection).length - 1 do
//    begin
//      child := (node.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
//      attr := child.getAttribute('data-id', 0);
//      if attr <> 0 then
//      begin
//        SetLength(AEagleList, Length(AEagleList) + 1);
//        AEagleList[Length(AEagleList) - 1] := attr;
//      end;
//    end;
//  end
//  else
//  begin
    node := FindNodeByAttrExStarts(document.Body, 'div', 'id', 'eagleplayer-');
  OutputDebugString(PChar('Seaech eagleplayer: ' + IntToHex(Integer(node), 8)));
end;


end.
