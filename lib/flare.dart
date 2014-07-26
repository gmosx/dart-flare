library flare;

const METADATA_EXTENSION = 'meta.json';

final PRIVATE_RE = new RegExp(r'/_');
final TMPL_RE = new RegExp(r'.tmpl.');
final INC_RE = new RegExp(r'.inc.');